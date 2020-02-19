#!/usr/bin/env bash
# This scripts prepares the environment for Yocto builds

# Zondax manifest

if [ "$ZONDAX_CONF" == "dk2" ]; then
	echo "Using STM32 DK2 manifest"

	DISTRO=openstlinux-weston
	MACHINE=stm32mp1

	TAG_NAME=zondax-meta-20-02-19
	MANIFEST_URL=https://github.com/Zondax/oe-manifest.git

	IMAGE_DIR=tmp-glibc/deploy/images/stm32mp1
	IMAGE_NAME=st-image-weston

	ENV_SOURCE=layers/meta-st/scripts/envsetup.sh
	MANIFEST_FILE=default.xml

	FLASH_LAYOUT=FlashLayout_sdcard_stm32mp157c-dk2-optee.tsv
elif [ "$ZONDAX_CONF" == "bytesatwork" ]; then
	echo "Using Bytesatwork manifest"

	DISTRO=poky-bytesatwork
	MACHINE=bytedevkit

	TAG_NAME=zondax-meta-bytesatwork
	MANIFEST_URL=https://github.com/Zondax/oe-manifest.git

	# for some reason after sourcing MACHINE is empty
	IMAGE_DIR=tmp/deploy/images/bytedevkit
	IMAGE_NAME=devbase-image-bytesatwork

	ENV_SOURCE="setup-environment build"
	MANIFEST_FILE=bytesatwork.xml

	FLASH_LAYOUT=FlashLayout_sdcard_stm32mp157c-bytedevkit.tsv
fi

ROOT_DIR=/home/zondax/shared/manifests/${IMAGE_NAME}
#declare EULA_${MACHINE}=1
EULA_stm32mp1=1

BUILD_DIR=$ROOT_DIR/build
echo
echo "-----------------------------------------------------------------------"
echo "Fetching \"${DISTRO}\" distribution."
echo "From ${MANIFEST_URL}/${MANIFEST_FILE}, tag: ${TAG_NAME}"
echo "The recommended development image is: ${IMAGE_NAME}"
echo "-----------------------------------------------------------------------"
echo

# Checkout and clone manifest
mkdir -p ${ROOT_DIR}
cd ${ROOT_DIR}
repo init --depth=1 -u ${MANIFEST_URL} -b refs/tags/${TAG_NAME} -m ${MANIFEST_FILE}
repo sync -c -j$(nproc --all)

echo "-----------------------------------------------------------------------"
echo Setting up environment:
echo "-----------------------------------------------------------------------"

source ${ENV_SOURCE}

echo "-----------------------------------------------------------------------"
echo Adding Zondax Meta layer:
echo "-----------------------------------------------------------------------"

bitbake-layers add-layer ../layers/meta-zondax
bitbake-layers show-layers

