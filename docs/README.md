# zondax-yocto-images

## How the `build` script works

Suppose we run `make build dk2`:

> TIP! if you want to play with bitbake use `make shell <TARGET>` instead

- Then `shared/build.sh dk2` will _source_ `zxconfigure`

- `zxconfigure` contains configuration specific for each possible target.
  For instance, in the case of `dk2`

  ```shell
  MACHINE=stm32mp1
  IMAGE_DIR=tmp/deploy/images/stm32mp1
  FLASH_LAYOUT=FlashLayout_sdcard_stm32mp157c-dk2-optee.tsv
  BSP_LAYERS=(meta-st-stm32mp)
  ```

  | variable     | description                                   |
  | ------------ | --------------------------------------------- |
  | MACHINE      | ????                                          |
  | IMAGE_DIR    | location where the final image will be placed |
  | FLASH_LAYOUT | image layout configuration file               |
  | BSP_LAYERS   | specific BSP layers to use for this image     |

  after setting these values, it will configure bitbake:

  - Add required layers and custom Zondax layers
  - Show what layers will be included:

    ```text
    layer                 path                                      priority
    ==========================================================================
    meta                  /home/zondax/shared/zondbox-distro/poky/meta  5
    meta-poky             /home/zondax/shared/zondbox-distro/poky/meta-poky  5
    meta-yocto-bsp        /home/zondax/shared/zondbox-distro/poky/meta-yocto-bsp  5
    meta-oe               /home/zondax/shared/zondbox-distro/meta-openembedded/meta-oe  6
    meta-python           /home/zondax/shared/zondbox-distro/meta-openembedded/meta-python  7
    meta-st-stm32mp       /home/zondax/shared/zondbox-distro/meta-st-stm32mp  6
    meta-zondax           /home/zondax/shared/zondbox-distro/meta-zondax  15
    ```

  - List all packages that will be included in the image

    ```text
    attr
    base-files
    base-passwd
    ...
    update-rc.d
    util-linux
    xz
    zlib
    ```

- Then we are back to `build.sh` and `bitbake` will start building images and partitions. This may take time the first time. A lot of data is cache, so other builds will be faster.
- Once the build finishes, a layout will be used to assemble the partitions into a single image.

  ```text
  Populate raw image with image content:
  [ FILLED ] part 1:    fsbl1, image: tf-a-stm32mp157c-dk2-optee.stm32
  [ FILLED ] part 2:    fsbl2, image: tf-a-stm32mp157c-dk2-optee.stm32
  [ FILLED ] part 3:     ssbl, image: u-boot-stm32mp157c-dk2-optee.stm32
  [ FILLED ] part 4:     teeh, image: tee-header_v2-stm32mp157c-dk2-optee.stm32
  [ FILLED ] part 5:     teed, image: tee-pageable_v2-stm32mp157c-dk2-optee.stm32
  [ FILLED ] part 6:     teex, image: tee-pager_v2-stm32mp157c-dk2-optee.stm32
  [ FILLED ] part 7:   bootfs, image: st-image-bootfs-zondbox-distro-stm32mp1.ext4
  [ FILLED ] part 8: vendorfs, image: st-image-vendorfs-zondbox-distro-stm32mp1.ext4
  [ FILLED ] part 9:   rootfs, image: core-image-minimal-stm32mp1.ext4
  [ FILLED ] part 10:   userfs, image: st-image-userfs-zondbox-distro-stm32mp1.ext4
  ```

- Then you can use balena etcher (or similar) to copy the image to an sdcard.

## I want to develop!

### Using Qemu

- Run `make build qemu` or `make build qemu8`. This will build the corresponding images
- If you are in a computer with X11: `make run-term qemu` or `make run-term qemu8`
- Otherwise use `make run-term qemu` or `make run-term qemu8`
  - In this case, you will need to open two other terminals and run:

    ```shell
    telnet 127.0.0.1 54320 # For REE
    telnet 127.0.0.1 54321 # For TEE
    ```

- Once you have the two terminals connected to Qemu. Type `c` start the emulation. You will see both REE and TEE booting. Wait for the prompt. Username `root` and no password.
- The script will automatically mount `./shared` from your host in qemu's `/mnt`. You will find `run_app.sh` that will execute `hello_rustee`. This is a very simple example we have prepared.

- Try running hello_rustee:

    ```text
    root@qemu-optee32:~# /mnt/run_app.sh 
    ------------------------ Installing TAs -------------------------------
    ------------------------ Launching HOST -------------------------------

    [RUSTEE] <= 12345
    [RUSTEE] => 12348
    ```

### But I want to modify the code!

To do this, you can create a local workspace. Basically you need to run `make workspace <TARGET> <PACKAGE>`. Let's try this.

- Run `make workspace qemu optee-hellorustee`. This will clone the sources of the package and create a link to `sources/optee-hellorustee`.
- You can now open your favourite editor and work there.
- **OPTION1** Make changes! If you want to build. You can rebuild the image. This will rebuild the image using the source code that you have "detached".
- **OPTION3** 
- **OPTION3** But there is another option! The actual place where detached is at `shared/zondbox-distro/build/workspace/sources/optee-hellorustee/src`. In qemu, this is mounted at `/mnt/zondbox-distro/build/workspace/sources/optee-hellorustee/src` so if you want, you can also make changes in your host and access that too inside qemu.
