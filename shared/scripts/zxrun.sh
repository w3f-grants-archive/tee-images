#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/zxsettings

VIRTFS_DIR=$DIR/..

IMAGEOUTPUT_DIR=$DIR/../images/${ZONDAX_CONF}
COMMON_PARAMS="-s -S \
		-nographic \
		-machine virt,secure=on \
		-bios bl1.bin \
		-serial telnet:0.0.0.0:54320,server,nowait \
		-serial telnet:0.0.0.0:54321,server,nowait \
		-m 1058 \
		-d unimp -semihosting-config enable,target=native \
		-object rng-random,filename=/dev/urandom,id=rng0 \
		-device virtio-rng-pci,rng=rng0,max-bytes=1024,period=1000 \
		-netdev user,id=vmnic,hostfwd=tcp::${QEMU_HOST_SSH_FWD}-:22 \
		-device virtio-net-device,netdev=vmnic \
		-fsdev local,id=fsdev0,path=${VIRTFS_DIR},security_model=none \
		-device virtio-9p-device,fsdev=fsdev0,mount_tag=host"

echo "Please use telnet to receive console output: "
echo "    NW output $ telnet 127.0.0.1 54320"
echo "    SW output $ telnet 127.0.0.1 54321"
echo "To mount host 'shared' directory run:"
echo "    $ mount -t 9p -o trans=virtio host <mount_point>"

if [ "$ZONDAX_CONF" == "qemu8" ]; then
	set -e

	ROOT_NATIVE=$BUILD_DIR/tmp/work/qemu_optee64-poky-linux/core-image-minimal/1.0-r0/recipe-sysroot-native

	cd $IMAGEOUTPUT_DIR && $ROOT_NATIVE/usr/bin/qemu-system-aarch64 \
		${COMMON_PARAMS} \
		-cpu cortex-a57 \
		-initrd rootfs.cpio.gz \
		-kernel Image -no-acpi
elif [ "$ZONDAX_CONF" == "qemu" ]; then
	set -e

	ROOT_NATIVE=$BUILD_DIR/tmp/work/qemu_optee32-poky-linux-gnueabi/core-image-minimal/1.0-r0/recipe-sysroot-native

	cd $IMAGEOUTPUT_DIR && $ROOT_NATIVE/usr/bin/qemu-system-arm \
		${COMMON_PARAMS} \
		-cpu cortex-a15
fi
