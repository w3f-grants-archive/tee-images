#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/zxenv.sh

# Build
bitbake ${IMAGE_NAME}

IMAGE_DIR="${BUILDDIR}/${IMAGE_DIR}"

echo "IMAGEDIR  : "$IMAGE_DIR
echo "IMAGENAME : "$IMAGE_NAME

# Create image using layout
$IMAGE_DIR/scripts/create_sdcard_from_flashlayout.sh \
	$IMAGE_DIR/flashlayout_$IMAGE_NAME/$FLASH_LAYOUT

# Copy raw images
cp $IMAGE_DIR/*.raw $HOME/shared/images/
