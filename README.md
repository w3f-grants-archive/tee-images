# ARM-TEE-Image

## Build or pull the container

- `make build` to build the container image
- `make pull` to retrieve the latest published container image

## Log in

the `shared` directory can be used to exchange information with the build container. You can always edit configuration files, get access to images, etc. from `shared`

- `make shell` to login into the container

Once inside the container, to initialize the OpenEmbedded environment plus some handy utilities we included:
```
stm
```

This will give you a zsh session with environment ready to start.
Before you start building please let bitbake know about meta-zondax layer:
```
-> bitbake-layers add-layer ../layers/meta-zondax
```

Afterwards `meta-zondax` layer should be listed in the layer list:
```
bitbake-layers show-layers
NOTE: Starting bitbake server...
layer                 path                                      priority
==========================================================================
meta-python           /home/zondax/shared/zondax-meta-openstlinux-4.19-thud-mp1/layers/meta-openembedded/meta-python  7
meta-oe               /home/zondax/shared/zondax-meta-openstlinux-4.19-thud-mp1/layers/meta-openembedded/meta-oe  6
meta-oe               /home/zondax/shared/zondax-meta-openstlinux-4.19-thud-mp1/layers/meta-openembedded/meta-oe  6
meta-gnome            /home/zondax/shared/zondax-meta-openstlinux-4.19-thud-mp1/layers/meta-openembedded/meta-gnome  7
meta-xfce             /home/zondax/shared/zondax-meta-openstlinux-4.19-thud-mp1/layers/meta-openembedded/meta-xfce  7
meta-initramfs        /home/zondax/shared/zondax-meta-openstlinux-4.19-thud-mp1/layers/meta-openembedded/meta-initramfs  8
meta-multimedia       /home/zondax/shared/zondax-meta-openstlinux-4.19-thud-mp1/layers/meta-openembedded/meta-multimedia  6
meta-networking       /home/zondax/shared/zondax-meta-openstlinux-4.19-thud-mp1/layers/meta-openembedded/meta-networking  5
meta-webserver        /home/zondax/shared/zondax-meta-openstlinux-4.19-thud-mp1/layers/meta-openembedded/meta-webserver  6
meta-filesystems      /home/zondax/shared/zondax-meta-openstlinux-4.19-thud-mp1/layers/meta-openembedded/meta-filesystems  6
meta-perl             /home/zondax/shared/zondax-meta-openstlinux-4.19-thud-mp1/layers/meta-openembedded/meta-perl  6
meta-python           /home/zondax/shared/zondax-meta-openstlinux-4.19-thud-mp1/layers/meta-openembedded/meta-python  7
meta-st-stm32mp       /home/zondax/shared/zondax-meta-openstlinux-4.19-thud-mp1/layers/meta-st/meta-st-stm32mp  6
meta-qt5              /home/zondax/shared/zondax-meta-openstlinux-4.19-thud-mp1/layers/meta-qt5  7
meta-st-openstlinux   /home/zondax/shared/zondax-meta-openstlinux-4.19-thud-mp1/layers/meta-st/meta-st-openstlinux  5
meta                  /home/zondax/shared/zondax-meta-openstlinux-4.19-thud-mp1/layers/openembedded-core/meta  5
meta-zondax           /home/zondax/shared/zondax-meta-openstlinux-4.19-thud-mp1/layers/meta-zondax  7
```

To check what optee-related projects will be built for this image recipe, run:
```
$ bitbake -g st-image-core && cat pn-buildlist | grep -ve "native" | sort | uniq
...
opkg-utils
optee-client
optee-helloworld
optee-os-stm32mp
...
```

You can build the full/default image:
```
bitbake st-image-weston
```

or try something leaner instead
```
bitbake st-image-core
```

## Creating an image

There is a script to build you sdcard image at `$IMAGEDIR/scripts/create_sdcard_from_flashlayout.sh` and many layouts that you can use.

You can list layouts with:
```
ls $IMAGEDIR/flashlayout*/
```

As an example, you can run:
```
$IMAGEDIR/scripts/create_sdcard_from_flashlayout.sh $IMAGEDIR/flashlayout_st-image-core/FlashLayout_sdcard_stm32mp157c-dk2-optee.tsv
```

this will generate an image:
```
......

RAW IMAGE generated: /home/zondax/shared/openstlinux-4.19-thud-mp1-19-10-09/build-openstlinuxweston-stm32mp1/tmp-glibc/deploy/images/stm32mp1/flashlayout_st-image-core/../flashlayout_st-image-core_FlashLayout_sdcard_stm32mp157c-dk2-optee.raw

WARNING: before to use the command dd, please umount all the partitions associated to SDCARD.

    sudo umount `lsblk --list | grep mmcblk0 | grep part | gawk '{ print $7 }' | tr '\n' ' '`

To put this raw image on sdcard:
    sudo dd if=/home/zondax/shared/openstlinux-4.19-thud-mp1-19-10-09/build-openstlinuxweston-stm32mp1/tmp-glibc/deploy/images/stm32mp1/flashlayout_st-image-core/../flashlayout_st-image-core_FlashLayout_sdcard_stm32mp157c-dk2-optee.raw of=/dev/mmcblk0 bs=8M conv=fdatasync status=progress
```

Now you can go outside the container and run:

> Depending on your setup, it is possible that `/dev/mmcblk0` is not the correct device
>
> instead of `/dev/mmcblk0` it is possible that you need to use something like `/dev/sd?` if you are using card readers, etc.

```
sudo dd if=../flashlayout_st-image-weston/../flashlayout_st-image-weston_FlashLayout_sdcard_stm32mp157c-dk2-optee.raw of=/dev/mmcblk0 bs=8M conv=fdatasync status=progress oflag=direct
```
Notice the `oflag=direct` that skip catching and will show progress all the time.

## Booting and running tests

Insert the SD card and boot your device.

> TODO: EXPLAIN minicom/serial, etc.

Now you can run the OPTEE test harness

```
xtest
```

If everything went well, you should be able to see that all test pass.
