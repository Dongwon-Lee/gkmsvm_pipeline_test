#!/bin/bash

set -o errexit
set -o nounset

POSQCF=$1
GENOME=$2
RSEED=$3
NFOLD=$4
PREFIX=$5

NEGF=${PREFIX}.bed
NEG_TRAINF=${PREFIX}.tr.bed
NEG_TESTF=${PREFIX}.te.bed
NEG_TRSEQF=${NEG_TRAINF%.bed}.fa
NEG_TESEQF=${NEG_TESTF%.bed}.fa

# generate negative set
python3 ${SCRIPTDIR}/nullseq_generate.py -r $RSEED -o $NEGF -x $NFOLD $POSQCF $GENOME ${DATADIR}/nullseq_indice/$GENOME

# split the negative set into training and test
awk -v OFS="\t" '$1!="chr9"' $NEGF >$NEG_TRAINF
awk -v OFS="\t" '$1=="chr9"' $NEGF >$NEG_TESTF

# fetch genomic sequences
python3 ${SCRIPTDIR}/fetchseqs.py -d ${DATADIR}/genomes/$GENOME $NEG_TRAINF $NEG_TRSEQF

python3 ${SCRIPTDIR}/fetchseqs.py -d ${DATADIR}/genomes/$GENOME $NEG_TESTF $NEG_TESEQF
