FROM arm64v8/alpine:3.14
LABEL maintainer.name="The runX Project" \
      maintainer.email="eve-runx@lists.lfedge.org"

ENV QEMU_VERSION=5.2.0
ENV USER root

RUN mkdir /build
WORKDIR /build

# build depends
RUN \
    apk update && \
    apk add argp-standalone && \
    apk add autoconf && \
    apk add automake && \
    apk add bash && \
    apk add curl && \
    apk add dev86 && \
    apk add gcc  && \
    apk add git && \
    apk add glib-dev && \
    apk add linux-headers && \
    apk add make && \
    apk add musl-dev && \
    apk add ninja && \
    apk add patch  && \
    apk add xz-dev && \
    apk add zlib-dev && \
    apk add elfutils-dev && \
    apk add openssl-dev && \
    apk add bison && \
    apk add flex && \
    apk add bc && \
    apk add python3  && \
    apk add pixman-dev && \
    apk add pkgconf && \
    \
    curl -fsSLO https://download.qemu.org/qemu-"$QEMU_VERSION".tar.xz && \
    tar xvJf qemu-"$QEMU_VERSION".tar.xz && \
    cd qemu-"$QEMU_VERSION" && \
    ./configure                \
        --target-list=aarch64-softmmu \
        --enable-system        \
        --disable-blobs        \
        --disable-bsd-user     \
        --disable-debug-info   \
        --disable-glusterfs    \
        --disable-gtk          \
        --disable-guest-agent  \
        --disable-linux-user   \
        --disable-sdl          \
        --disable-spice        \
        --disable-tpm          \
        --disable-vhost-net    \
        --disable-vhost-scsi   \
        --disable-vhost-user   \
        --disable-vhost-vsock  \
        --disable-virtfs       \
        --disable-vnc          \
        --disable-werror       \
        --disable-xen          \
        --disable-safe-stack   \
        --disable-libssh       \
        --disable-opengl       \
        --disable-tools        \
        --disable-virglrenderer  \
        --disable-stack-protector  \
        --disable-containers   \
        --disable-replication  \
        --disable-cloop        \
        --disable-dmg          \
        --disable-vvfat        \
        --disable-vdi          \
        --disable-parallels    \
        --disable-qed          \
        --disable-bochs        \
        --disable-qom-cast-debug  \
        --disable-vhost-vdpa   \
        --disable-vhost-kernel \
        --disable-qcow1        \
        --disable-live-block-migration \
    && \
    make -j$(nproc) && \
    cp ./build/qemu-system-aarch64 / && \
    cd /build && \
    rm -rf qemu-"$QEMU_VERSION"* && \
    rm -rf /tmp/* && \
    rm -f /var/cache/apk/*
