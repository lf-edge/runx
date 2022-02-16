#!/bin/bash

set -ex

apk update
apk add \
  uboot-tools \
  dtc \
  curl \
  git \
  file \
  sed \
  coreutils \
  py3-requests

cd binaries

mkdir -p rootfs
cd rootfs
tar xvzf ../initrd.tar.gz
mkdir proc
mkdir run
mkdir srv
mkdir sys
rm var/run

# runx, just overwrite runc since it's the most containerd independent
cp -ar ../../target/* .
mv usr/bin/runc usr/bin/runc.orig
mv usr/sbin/runX usr/bin/runc
# xen, also give qemu/imagebuilder a copy
tar xfz ../xen.tar.gz
cp ./boot/xen ../

# https://github.com/NotGlop/docker-drag/blob/master/docker_pull.py
curl -fsSLO https://raw.githubusercontent.com/NotGlop/docker-drag/5413165a2453aa0bc275d7dc14aeb64e814d5cc0/docker_pull.py
python3 ./docker_pull.py arm64v8/busybox:1.33.1
rm docker_pull.py
mv arm64v8_busybox.tar root/

echo "memory = 512
" > root/memory.xl

echo "#!/bin/bash

export LD_LIBRARY_PATH=/usr/local/lib
bash /etc/init.d/xencommons start

mount -t tmpfs cgroup_root /sys/fs/cgroup
mkdir /sys/fs/cgroup/cpuset
mkdir /sys/fs/cgroup/devices
mkdir /sys/fs/cgroup/memory
mkdir /sys/fs/cgroup/cpu
mount -t cgroup cpuset -o cpuset /sys/fs/cgroup/cpuset
mount -t cgroup devices -o devices /sys/fs/cgroup/devices
mount -t cgroup memory -o memory /sys/fs/cgroup/memory
mount -t cgroup cpu -o cpu /sys/fs/cgroup/cpu
sleep 5

containerd &
sleep 5

ctr image import /root/arm64v8_busybox.tar
sleep 5
ctr run -t --no-pivot --env XLCONF=/root/memory.xl docker.io/arm64v8/busybox:1.33.1 busybox /bin/sh
" > etc/local.d/xen.start
chmod +x etc/local.d/xen.start

echo "rc_verbose=yes" >> etc/rc.conf
find . |cpio -H newc -o|gzip > ../xen-rootfs.cpio.gz
cd ../..

# XXX QEMU looks for "efi-virtio.rom" even if it is unneeded
curl -fsSLO https://github.com/qemu/qemu/raw/v5.2.0/pc-bios/efi-virtio.rom
./binaries/qemu-system-aarch64 \
   -machine virtualization=true \
   -cpu cortex-a57 -machine type=virt \
   -m 1024 -display none \
   -machine dumpdtb=binaries/virt-gicv3.dtb
# XXX disable pl061 to avoid Linux crash
dtc -I dtb -O dts binaries/virt-gicv3.dtb > binaries/virt-gicv3.dts
sed 's/compatible = "arm,pl061.*/status = "disabled";/g' binaries/virt-gicv3.dts > binaries/virt-gicv3-edited.dts
dtc -I dts -O dtb binaries/virt-gicv3-edited.dts > binaries/virt-gicv3.dtb

# ImageBuilder
echo 'MEMORY_START="0x40000000"
MEMORY_END="0x80000000"

DEVICE_TREE="virt-gicv3.dtb"
XEN="xen"
DOM0_KERNEL="Image"
DOM0_RAMDISK="xen-rootfs.cpio.gz"
XEN_CMD="console=dtuart dom0_mem=1024M"

NUM_DOMUS=0

LOAD_CMD="tftpb"
UBOOT_SOURCE="boot.source"
UBOOT_SCRIPT="boot.scr"' > binaries/config
rm -rf imagebuilder
git clone https://gitlab.com/ViryaOS/imagebuilder
bash imagebuilder/scripts/uboot-script-gen -t tftp -d binaries/ -c binaries/config

# Run the test
rm -f smoke.serial
set +e
echo "  virtio scan; dhcp; tftpb 0x40000000 boot.scr; source 0x40000000"| \
timeout -k 1 720 \
./binaries/qemu-system-aarch64 \
    -machine virtualization=true \
    -cpu cortex-a57 -machine type=virt \
    -m 2048 -monitor none -serial stdio \
    -smp 2 \
    -no-reboot \
    -device virtio-net-pci,netdev=n0 \
    -netdev user,id=n0,tftp=binaries \
    -bios binaries/u-boot.bin |& tee smoke.serial

set -e
(grep -q 'Executing "/bin/sh"' smoke.serial) || exit 1
exit 0
