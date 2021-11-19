FROM --platform=linux/x86_64 busybox:latest AS busybox-x86

FROM arm64v8/alpine:3.12
LABEL maintainer.name="The runX Project" \
      maintainer.email="eve-runx@lists.lfedge.org"

ENV LINUX_VERSION=5.10.30
ENV USER root

RUN mkdir /build
WORKDIR /build
COPY "$LINUX_VERSION"-arm64v8.config.diff ./

# build depends
RUN \
    # apk
    apk update && \
    \
    # kernel
    apk add argp-standalone && \
    apk add autoconf && \
    apk add automake && \
    apk add bash && \
    apk add curl && \
    apk add dev86 && \
    apk add gcc  && \
    apk add g++ && \
    apk add git && \
    apk add linux-headers && \
    apk add make && \
    apk add patch  && \
    apk add xz-dev && \
    apk add zlib-dev && \
    apk add elfutils-dev && \
    apk add openssl-dev && \
    apk add bison && \
    apk add flex && \
    apk add bc && \
    \
    # Build the kernel
    curl -fsSLO https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-"$LINUX_VERSION".tar.xz && \
    tar xvJf linux-"$LINUX_VERSION".tar.xz && \
    cd linux-"$LINUX_VERSION" && \
    make defconfig && \
    cat ../"$LINUX_VERSION"-arm64v8.config.diff >> .config && \
    make -j$(nproc) Image.gz && \
    cp arch/arm64/boot/Image / && \
    cd /build && \
    rm -rf linux-"$LINUX_VERSION"* && \
    rm -rf /tmp/* && \
    rm -f /var/cache/apk/*

COPY --from=busybox-x86 /bin/busybox /usr/local/bin/busybox-x86

RUN \
    ln -s /usr/local/bin/busybox-x86 /usr/local/bin/sh && \
    ln -s /usr/local/bin/busybox-x86 /usr/local/bin/mkdir && \
    ln -s /usr/local/bin/busybox-x86 /usr/local/bin/cp && \
    echo '#!/usr/local/bin/sh' >> /usr/local/bin/bash && \
    echo '/usr/local/bin/sh $*' >> /usr/local/bin/bash && \
    chmod +x /usr/local/bin/bash
