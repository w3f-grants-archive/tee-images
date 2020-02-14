#!/usr/bin/env bash
# This scripts prepares the environment for Yocto builds

# Original manifest from ST
# TAG_NAME=openstlinux-4.19-thud-mp1-19-10-09
# MANIFEST_URL=https://github.com/STMicroelectronics/oe-manifest.git

# Zondax manifest
DISTRO=poky-bytesatwork
MACHINE=bytedevkit
BRANCH=warrior
MANIFEST_URL=https://github.com/bytesatwork/bsp-platform-st.git
EULA=1

ROOTDIR=/home/zondax/shared/${BRANCH}

# Checkout and clone manifest
mkdir -p ${ROOTDIR}
cd ${ROOTDIR}
repo init -u ${MANIFEST_URL} -b ${BRANCH} -m default.xml
repo sync

source setup-environment build

# for some reason after sourcing MACHINE is empty
IMAGEDIR=$BUILDDIR/tmp/deploy/images/bytedevkit

echo
echo The recommended development image is: devbase-image-bytesatwork
echo
