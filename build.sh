#!/bin/bash

# Copyright 2018 Stefano Stabellini
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
set -o pipefail

execs="start delete state serial_bridge serial_start"

# Clean the repo, but save the vendor area
if [ "x${1:-}" != "x" ] && [ "clean" == "$1" ]; then
    echo "cleaning project"
    rm -rf kernel/out
    rm -rf kernel/build
    rm -rf target

    exit 0
fi

# Support cross-compiling via ARCH variable
if [[ -z "$ARCH" ]]
then
    ARCH=`uname -p`
fi
if [[ $ARCH = "x86_64" ]]
then
    export ARCH="x86"
elif [[ $ARCH = "aarch64" ]]
then
    export ARCH="arm64"
elif [[ $ARCH = "arm*" ]]
then
    export ARCH="arm"
else
    echo Architecture not supported
    exit 1
fi

mkdir -p target/usr/share/runX
for i in $execs; do
    cp files/$i target/usr/share/runX
done

cd gobuild
if [[ $ARCH = "x86" ]]
then
    make GOARCH=amd64
else
    make GOARCH=$ARCH
fi
cd -
cp gobuild/serial_fd_handler target/usr/share/runX/
cp gobuild/recvtty target/usr/share/runX/

mkdir -p target/usr/sbin
cp runX target/usr/sbin

# Build the kernel and initrd
kernel/make-kernel
cp kernel/out/kernel target/usr/share/runX
kernel/make-initrd
cp kernel/out/initrd target/usr/share/runX
