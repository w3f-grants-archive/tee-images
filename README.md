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

This will give you a zsh session with environment ready to start:

You can build the full/default image:
```
bitbake st-image-weston
bitbake optee-os-stm32mp        # OP-TEE core firmware
bitbake optee-client            # OP-TEE client
bitbake optee-test              # OP-TEE test suite (optional)
bitbake optee-examples
```

or try something leaner instead
```
bitbake st-image-core
bitbake optee-os-stm32mp        # OP-TEE core firmware
bitbake optee-client            # OP-TEE client
bitbake optee-test              # OP-TEE test suite (optional)
bitbake optee-examples
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