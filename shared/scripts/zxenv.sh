#!/usr/bin/env bash
# This script prepares the environment for Yocto builds

PATH=$PATH:$HOME/shared/scripts

# Zondax manifest
if [ "$ZONDAX_CONF" == "dk2" ]; then
	echo "Building for STM32 DK2"

	export DISTRO=zondbox-distro
	export MACHINE=stm32mp1

	MANIFEST_BRANCH=master
	MANIFEST_URL=https://github.com/Zondax/zondbox-manifest
	MANIFEST_FILE=default.xml

	IMAGE_DIR=tmp/deploy/images/stm32mp1
	IMAGE_NAME=core-image-minimal

	ENV_SOURCE="poky/oe-init-build-env build"
	FLASH_LAYOUT=FlashLayout_sdcard_stm32mp157c-dk2-optee.tsv

	BSP_LAYERS=(meta-st-stm32mp meta-st-stm32mp-addons)
elif [ "$ZONDAX_CONF" == "bytesatwork" ]; then
	echo "Error: Bytesatwork is not supported"

	exit 1
elif [ "$ZONDAX_CONF" == "imx8mq" ]; then
	echo "Error: MCIMX8M-EVKB is not supported"

	exit 1
fi

ROOT_DIR=$HOME/shared/${DISTRO}
declare EULA_${MACHINE}=1

BUILD_DIR=$ROOT_DIR/build
echo
echo "-----------------------------------------------------------------------"
echo "Fetching \"${DISTRO}\" distribution."
echo "From ${MANIFEST_URL}/${MANIFEST_FILE}, branch/tag: ${MANIFEST_BRANCH}"
echo "The recommended development image is: ${IMAGE_NAME}"
echo "-----------------------------------------------------------------------"
echo

# Checkout and clone manifest
mkdir -p ${ROOT_DIR}
cd ${ROOT_DIR}
repo init --depth=1 --no-clone-bundle -u ${MANIFEST_URL} -b ${MANIFEST_BRANCH} -m ${MANIFEST_FILE}
repo sync -c -j$(nproc --all) --fetch-submodules --current-branch --no-clone-bundle

echo "-----------------------------------------------------------------------"
echo Setting up environment:
echo "-----------------------------------------------------------------------"

source ${ENV_SOURCE}

echo "-----------------------------------------------------------------------"
echo Adding all needed distro layers:
echo "-----------------------------------------------------------------------"

bitbake-layers add-layer ${ROOT_DIR}/meta-openembedded/meta-oe/
bitbake-layers add-layer ${ROOT_DIR}/meta-openembedded/meta-python/

echo "-----------------------------------------------------------------------"
echo Adding all needed BSP layers:
echo "-----------------------------------------------------------------------"

for i in "${BSP_LAYERS[@]}"; do bitbake-layers add-layer ${ROOT_DIR}/$i; done

echo "-----------------------------------------------------------------------"
echo Adding Zondax meta layer:
echo "-----------------------------------------------------------------------"

bitbake-layers add-layer ${ROOT_DIR}/meta-zondax/
bitbake-layers show-layers

echo "-----------------------------------------------------------------------"
echo Packages that going to be built:
echo "-----------------------------------------------------------------------"

bitbake -g core-image-minimal && cat pn-buildlist | grep -ve "native" | sort | uniq
echo
echo "-----------------------------------------------------------------------"
echo To build run zxbuild.sh
echo Bitbake cheatsheet
echo "   bitbake <image>                    e.g. bitbake ${IMAGE_NAME}"
echo "   bitbake <recipe>                   e.g. bitbake optee-hellorustee"
echo "   bitbake <package> -c listtasks     e.g. bitbake optee-hellorustee -c listtasks"
echo "   bitbake <package> -c <taskname>    e.g. bitbake optee-hellorustee -c devshell"
echo "   bitbake-layers show-layers"
echo "   bitbake-layers show-recipes"
echo "-----------------------------------------------------------------------"
