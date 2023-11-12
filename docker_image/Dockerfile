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

# UMD mirror site for https apt repositories
COPY sources.list /etc/apt/sources.list 

# install app 
RUN apt-get update && apt-get install -y python3 python3-pip git ca-certificates

# after install ca-certificates, we need to remove the following file
RUN rm -f /etc/apt/apt.conf.d/99verify-peer.conf

# check if it works
RUN apt-get update

RUN mkdir /software
WORKDIR /software

RUN git clone https://github.com/Dongwon-Lee/lsgkm.git && \
    cd lsgkm/src && make && make install

ENV PATH="/software/lsgkm/bin:${PATH}"
