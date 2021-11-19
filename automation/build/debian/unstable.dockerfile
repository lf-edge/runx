FROM debian:unstable
LABEL maintainer.name="The runX Project" \
      maintainer.email="eve-runx@lists.lfedge.org"

ENV USER root

RUN mkdir /build
WORKDIR /build

# build depends
RUN apt-get update && \
    apt-get --quiet --yes install \
        build-essential \
        cpio \
        bc \
        findutils \
        patch \
        perl \
        wget \
        curl \
        file \
        zlib1g-dev \
        libncurses5-dev \
        libssl-dev \
        pkg-config \
        flex \
        bison \
        git \
        gnupg \
        apt-transport-https \
        xz-utils \
        qemu-system-aarch64 \
        elfutils \
        gcc-9-aarch64-linux-gnu \
        device-tree-compiler \
        python3 \
        python3-requests \
        coreutils \
        sed \
        u-boot-tools \
        && \
    ln -s /usr/bin/aarch64-linux-gnu-gcc-9 /usr/bin/aarch64-linux-gnu-gcc && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists* /tmp/* /var/tmp/*
