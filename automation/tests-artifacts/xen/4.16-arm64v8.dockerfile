FROM arm64v8/alpine:3.14
LABEL maintainer.name="The runX Project" \
      maintainer.email="eve-runx@lists.lfedge.org"

ENV USER root

ENV XEN_BRANCH=stable-4.16
RUN mkdir /build
WORKDIR /build

# build depends
RUN \
  # apk
  apk update && \
  \
  # xen build deps
  apk add argp-standalone && \
  apk add autoconf && \
  apk add automake && \
  apk add bash && \
  apk add curl && \
  apk add curl-dev && \
  apk add dev86 && \
  apk add dtc-dev && \
  apk add gcc  && \
  apk add g++ && \
  apk add clang  && \
  apk add gettext && \
  apk add git && \
  apk add iasl && \
  apk add libaio-dev && \
  apk add libfdt && \
  apk add linux-headers && \
  apk add make && \
  apk add musl-dev  && \
  apk add libc6-compat && \
  apk add ncurses-dev && \
  apk add patch  && \
  apk add python3-dev && \
  apk add texinfo && \
  apk add util-linux-dev && \
  apk add xz-dev && \
  apk add yajl-dev && \
  apk add zlib-dev && \
  \
  # qemu build deps
  apk add bison && \
  apk add flex && \
  apk add glib-dev && \
  apk add libattr && \
  apk add libcap-ng-dev && \
  apk add pixman-dev && \
  \
  # cleanup
  rm -rf /tmp/* && \
  rm -f /var/cache/apk/* && \
  \
  # ninja build
  git clone --branch release git://github.com/ninja-build/ninja.git && \
  cd ninja && \
  apk add cmake && \
  cmake -Bbuild-cmake -H. && \
  cmake --build build-cmake && \
  cp build-cmake/ninja /usr/bin && \
  cd .. && \
  # xen build
  git clone --branch "$XEN_BRANCH" http://xenbits.xen.org/git-http/xen.git  && \
  cd xen && \
  ./configure --enable-9pfs --with-extra-qemuu-configure-args="--disable-werror" &&\
  make -j$(nproc) dist && \
  cd dist/install && \
  tar cfz ../xen.tar.gz ./* && \
  mv ../xen.tar.gz / && \
  cd ../../../ && \
  rm -rf xen
