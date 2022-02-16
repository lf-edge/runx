FROM arm64v8/alpine:3.12
LABEL maintainer.name="The runX Project" \
      maintainer.email="eve-runx@lists.lfedge.org"

ENV USER root

RUN mkdir /build
WORKDIR /build

# build depends
RUN \
  # apk
  apk update && \
  \
  # for building runx
  apk add make && \
  apk add bash && \
  apk add bison && \
  apk add cpio && \
  apk add findutils && \
  apk add flex && \
  apk add gcc && \
  apk add glib-dev && \
  apk add gzip && \
  apk add openssl-dev && \
  apk add musl-dev && \
  apk add ncurses-dev && \
  apk add patch && \
  apk add perl && \
  apk add tar && \
  apk add wget && \
  \
  # for running qemu
  apk add elfutils && \
  apk add pixman && \
  apk add python3 && \
  apk add xz && \
  apk add zlib && \
  \
  # cleanup
  rm -rf /tmp/* && \
  rm -f /var/cache/apk/*
