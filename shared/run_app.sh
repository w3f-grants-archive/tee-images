#!/bin/sh
# ATTENTION: THIS SCRIPT IS SUPPOSED TO RUN INSIDE QEMU!!
DIR=`dirname $0`

ROOTFS="${DIR}/zondbox-distro/build/tmp/work/qemu_optee32-poky-linux-gnueabi/hello-rustee/0.1-r0/image"
RUSTEE_HOST=${ROOTFS}/usr/bin/hello-rustee
RUSTEE_TA=${ROOTFS}/lib/optee_armtz/*.ta

echo ------------------------ Installing TAs -------------------------------
cp $RUSTEE_TA /lib/optee_armtz/

echo ------------------------ Launching HOST -------------------------------
echo

if test -f "$RUSTEE_HOST"; then
	RUST_LOG=debug $RUSTEE_HOST
else
	echo "File binary does not exist. Did you compile your app?"
fi
