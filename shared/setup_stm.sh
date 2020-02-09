#!/usr/bin/env bash

TAG_NAME=openstlinux-4.19-thud-mp1-19-10-09
mkdir -p /home/zondax/shared/${TAG_NAME} && cd /home/zondax/shared/${TAG_NAME}
cd /home/zondax/shared/${TAG_NAME}
repo init -u https://github.com/STMicroelectronics/oe-manifest.git -b refs/tags/${TAG_NAME}
repo sync

export DISTRO=openstlinux-weston 
export MACHINE=stm32mp1

source layers/meta-st/scripts/envsetup.sh

# for some reason after sourcing MACHINE is empty
#export IMAGEDIR=$BUILDDIR/tmp-glibc/deploy/images/$MACHINE
export IMAGEDIR=$BUILDDIR/tmp-glibc/deploy/images/stm32mp1

zsh
