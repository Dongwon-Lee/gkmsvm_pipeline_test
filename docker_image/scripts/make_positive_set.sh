#!/bin/bash

set -o errexit
set -o nounset

INPUTF=$1 # narrowPeak file
PEAKTYPE=$2
GENOME=$3
EXTLEN=$4
TOPN=$5
PREFIX=$6

POSF0=${PREFIX}.bed
POSF0_PROF=${PREFIX}.prof

POSF=${PREFIX}.qc.bed
POSTOPNF=${PREFIX}.qc.topn.bed
TRAINF=${PREFIX}.qc.topn.tr.bed
TESTF=${PREFIX}.qc.topn.te.bed
TRSEQF=${PREFIX}.qc.topn.tr.fa
TESEQF=${PREFIX}.qc.topn.te.fa

# 0. decompress the input file if it is gzipped
if file -b --mime "$INPUTF" | grep -q "gzip"; then
    gunzip -c $INPUTF >${PREFIX}.unzipped.bed
    INPUTF=${PREFIX}.unzipped.bed
fi

# 1. make fixed length peaks
if [ $PEAKTYPE == "macs2" ]; then
    awk -v OFS="\t" -v SHFT=$EXTLEN \
    '$1 ~ /chr[0-9XY]+$/ {
    summit=$2+$10;
    if(summit-SHFT>0) print $1,summit-SHFT,summit+SHFT,$4,$8}' $INPUTF >$POSF0
elif [ $PEAKTYPE == "hotspot" ]; then
    awk -v OFS="\t" -v SHFT=$EXTLEN \
    '$1 ~ /chr[0-9XY]+$/ {
    summit=$2+$10;
    if(summit-SHFT>0) print $1,summit-SHFT,summit+SHFT,$4,$7}' $INPUTF >$POSF0
else
    awk -v OFS="\t" -v SHFT=$EXTLEN \
    '$1 ~ /chr[0-9XY]+$/ {
    summit=$2+$10;
    if(summit-SHFT>0) print $1,summit-SHFT,summit+SHFT,$4,0}' $INPUTF >$POSF0
fi

# 2. calculate profiles of the fixed length peaks
python3 ${SCRIPTDIR}/make_seq_prof.py $POSF0 $GENOME ${DATADIR}/nullseq_indice/$GENOME $POSF0_PROF

# 3. remove peaks with >1% of N bases & >70% of repeats
paste $POSF0_PROF $POSF0 | awk '$4<=0.7 && $5<=0.01' |cut -f 6- >$POSF

# 4. select top N from the filtered position
sort -grk 5 $POSF |head -n $TOPN |sort -k1,1 -k2,2n >$POSTOPNF

# 5. split the topN peaks into training and test sets (chr9 vs others)
awk -v OFS="\t" '$1!="chr9"' $POSTOPNF >$TRAINF
awk -v OFS="\t" '$1=="chr9"' $POSTOPNF >$TESTF

# 6. fetch sequences
python3 ${SCRIPTDIR}/fetchseqs.py -d ${DATADIR}/genomes/$GENOME $TRAINF $TRSEQF
python3 ${SCRIPTDIR}/fetchseqs.py -d ${DATADIR}/genomes/$GENOME $TESTF $TESEQF
