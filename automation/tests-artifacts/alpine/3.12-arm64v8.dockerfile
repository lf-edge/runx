FROM arm64v8/alpine:3.12
LABEL maintainer.name="The runX Project" \
      maintainer.email="eve-runx@lists.lfedge.org"

ENV USER root
ENV DAEMONIZE_RELEASE="release-1.7.8"

RUN mkdir /build
WORKDIR /build

RUN \
  # apk
  apk update && \
  \
  # xen runtime deps
  apk add argp-standalone && \
  apk add bash && \
  apk add busybox && \
  apk add curl && \
  apk add dbus && \
  apk add gettext && \
  apk add glib && \
  apk add openrc && \
  apk add libaio && \
  apk add libfdt && \
  apk add libgcc && \
  apk add libstdc++ && \
  apk add musl && \
  apk add ncurses && \
  apk add pixman && \
  apk add python2 && \
  apk add sudo && \
  apk add texinfo && \
  apk add udev && \
  apk add util-linux && \
  apk add xz-dev && \
  apk add yajl && \
  apk add zlib && \
  \
  # runx runtime deps
  apk add jq && \
  apk add socat && \
  apk add containerd && \
  \
  # daemonize build and install
  apk add gcc && \
  apk add autoconf && \
  apk add make && \
  apk add git && \
  apk add musl-dev && \
  git clone https://github.com/bmc/daemonize.git && \
  cd daemonize && \
  git checkout "$DAEMONIZE_RELEASE" && \
  sh configure && \
  make && \
  cp daemonize /usr/bin/ && \
  cd ../ && \
  rm -rf daemonize && \
  apk del gcc && \
  apk del autoconf && \
  apk del make && \
  apk del git && \
  apk del musl-dev && \
  \
  # Xen
  cd / && \
  # Minimal ramdisk environment in case of cpio output
  rc-update add udev && \
  rc-update add udev-trigger && \
  rc-update add udev-settle && \
  rc-update add networking sysinit && \
  rc-update add loopback sysinit && \
  rc-update add bootmisc boot && \
  rc-update add devfs sysinit && \
  rc-update add dmesg sysinit && \
  rc-update add cgroups sysinit && \
  rc-update add hostname boot && \
  rc-update add hwclock boot && \
  rc-update add hwdrivers sysinit && \
  rc-update add killprocs shutdown && \
  rc-update add modloop sysinit && \
  rc-update add modules boot && \
  rc-update add mount-ro shutdown && \
  rc-update add savecache shutdown && \
  rc-update add sysctl boot && \
  rc-update add local default && \
  cp -a /sbin/init /init && \
  echo "ttyS0" >> /etc/securetty && \
  echo "hvc0" >> /etc/securetty && \
  echo "ttyS0::respawn:/sbin/getty -L ttyS0 115200 vt100" >> /etc/inittab && \
  echo "hvc0::respawn:/sbin/getty -L hvc0 115200 vt100" >> /etc/inittab && \
  passwd -d "root" root && \
  \
  # Create rootfs
  cd / && \
  tar cvzf /initrd.tar.gz bin dev etc home init lib mnt opt root sbin usr var
