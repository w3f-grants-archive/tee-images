#!/bin/sh
# ATTENTION: THIS SCRIPT IS SUPPOSED TO RUN INSIDE QEMU!!
DIR=`dirname $0`

ROOTFS="${DIR}/zondbox-distro/build/tmp/work/qemu_optee32-poky-linux-gnueabi/core-image-minimal/1.0-r0/rootfs/"
RUSTEE_HOST=${ROOTFS}/usr/bin/hello_rustee

echo ------------------------ Installing TAs -------------------------------
cp $ROOTFS/lib/optee_armtz/*.ta /lib/optee_armtz/

echo ------------------------ Launching HOST -------------------------------
echo

if test -f "$RUSTEE_HOST"; then
	$RUSTEE_HOST
else
	echo "File binary does not exist. Did you compile your app?"
fi
