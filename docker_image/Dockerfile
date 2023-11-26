############################################################
# Dockerfile for gkmsvm-pipeline
# Based on Ubuntu 22.04
############################################################

FROM ubuntu:22.04

MAINTAINER Dongwon Lee

# disabling APT OCSP Verification.
# this is a workaround of outbound http block
RUN touch /etc/apt/apt.conf.d/99verify-peer.conf
RUN echo 'Acquire { https::Verify-Peer false }' > /etc/apt/apt.conf.d/99verify-peer.conf

# replace the original file with mirror sites that uses https apt repositories
COPY sources.list /etc/apt/sources.list 

# install app 
RUN apt-get update && apt-get install -y ca-certificates 

# after install ca-certificates, we need to remove the following file
RUN rm -f /etc/apt/apt.conf.d/99verify-peer.conf

# copy index file for generating negative regions
RUN mkdir /data
RUN mkdir /data/nullseq_indice
COPY nullseq_indice_hg38.tar.gz /data/nullseq_indice
WORKDIR /data/nullseq_indice
RUN tar -zxf nullseq_indice_hg38.tar.gz
RUN rm -f nullseq_indice_hg38.tar.gz

# copy reference sequences for making fasta files
RUN mkdir /data/genomes
COPY genome_hg38.tar /data/genomes
WORKDIR /data/genomes
RUN tar -xf genome_hg38.tar
RUN rm -f genome_hg38.tar

# make software directory
RUN mkdir /software
WORKDIR /software

# avoid interactive installation 
ENV DEBIAN_FRONTEND=noninteractive 

# install app 
RUN apt-get update && apt-get install -y python3 python3-pip r-base git file

# install lsgkm
RUN git clone https://github.com/Dongwon-Lee/lsgkm.git && \
    cd lsgkm/src && make && make install

# install R package
RUN R -e "install.packages('ROCR', dependencies=TRUE, repos='https://cran.r-project.org'); if (!library(ROCR, logical.return=T)) quit(status=10)"

# install bitarray package
RUN pip install bitarray

# copy scripts
COPY scripts/auc.R /software
COPY scripts/make_seq_prof.py /software
COPY scripts/fetchseqs.py /software
COPY scripts/nullseq_generate.py /software
COPY scripts/make_positive_set.sh /software
COPY scripts/make_negative_set.sh /software

# generate k-mers for scoring
RUN python3 /software/lsgkm/scripts/nrkmers.py 6 /data/6mers.fa
RUN python3 /software/lsgkm/scripts/nrkmers.py 7 /data/7mers.fa
RUN python3 /software/lsgkm/scripts/nrkmers.py 8 /data/8mers.fa
RUN python3 /software/lsgkm/scripts/nrkmers.py 9 /data/9mers.fa
RUN python3 /software/lsgkm/scripts/nrkmers.py 10 /data/10mers.fa
RUN python3 /software/lsgkm/scripts/nrkmers.py 11 /data/11mers.fa

# setup environment variables
ENV PATH="/software/lsgkm/bin:${PATH}"
ENV SCRIPTDIR="/software"
ENV DATADIR="/data"
