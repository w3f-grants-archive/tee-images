#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/zxenv.sh

IMAGENAME="st-image-weston"

# Adjust layers
bitbake-layers add-layer ../layers/meta-zondax
bitbake-layers show-layers

# Build
bitbake $IMAGENAME

echo "IMAGEDIR  : "$IMAGEDIR
echo "IMAGENAME : "$IMAGENAME

# Create image using layout
$IMAGEDIR/scripts/create_sdcard_from_flashlayout.sh $IMAGEDIR/flashlayout_$IMAGENAME/FlashLayout_sdcard_stm32mp157c-dk2-optee.tsv

# Copy raw images
\cp $IMAGEDIR/*.raw $HOME/shared/images/
