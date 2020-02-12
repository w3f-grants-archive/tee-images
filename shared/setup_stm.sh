#!/usr/bin/env bash

# Original manifest from ST
# TAG_NAME=openstlinux-4.19-thud-mp1-19-10-09
# MANIFEST_URL=https://github.com/STMicroelectronics/oe-manifest.git

# Zondax manifest
TAG_NAME=zondax-meta-openstlinux-4.19-thud-mp1
MANIFEST_URL=https://github.com/Zondax/oe-manifest.git

mkdir -p /home/zondax/shared/${TAG_NAME} && cd /home/zondax/shared/${TAG_NAME}
cd /home/zondax/shared/${TAG_NAME}
repo init -u ${MANIFEST_URL} -b refs/tags/${TAG_NAME} -m default.xml
repo sync

export DISTRO=openstlinux-weston
export MACHINE=stm32mp1

source layers/meta-st/scripts/envsetup.sh

# for some reason after sourcing MACHINE is empty
#export IMAGEDIR=$BUILDDIR/tmp-glibc/deploy/images/$MACHINE
export IMAGEDIR=$BUILDDIR/tmp-glibc/deploy/images/stm32mp1

zsh
