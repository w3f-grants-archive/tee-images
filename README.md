# zondax-yocto-images

## Targets

## Preconditions

- Install [Docker CE](https://docs.docker.com/engine/install/)
- We assume you are using Linux
- Our workflow requires that you have installed tmux

## Basics

We simplify the development process of TEE application in Yocto-based environments.

- `make help` to get a list of all available commands:

  ```shell
  Usage:
  make workspace <target> <recipe>  Create a workspace for <target> <recipe>
  make dev                          Launch a tmux ready environment for QEMU

  Others:
  make docker                       Fetch Zondax docker image
  make manifest                     Fetch Zondax repo manifest
  make manifest force               Force fetch/update Zondax repo manifest
  make login                        Simply login into docker container
  make toaster <target>             Run Toaster web interface
  make build <target>               Build image for <target>
  make shell <target>               Get shell for <target>
  make workspace <target> <recipe>  Create a workspace for <recipe>
  make run <qemu|qemu8>             Run QEMU ARMv7/QEMU ARMv8 emulation
  make run-term <qemu|qemu8>        Run QEMU emulation + fork xterm terminals for NW/SW consoles

  Typical <targets> = qemu qemu8 dk2

  ```

To start we recommend using:

- `make manifest` to retrieve docker and the latest published container image

## Build an image

- Run `make build <TARGET>`

  | Brand         | TARGET      | Description     |
  | ------------- | ----------- | --------------- |
  | ST            | dk2         | STM32MP157C-DK2 |
  | NXP           | imx8mq      | MCIMX8M-EVKB    |
  | Bytes at work | bytesatwork | Bytesatwork     |
  | Phytec        | polis       |                 |
  |               | pico-imx8m  |                 |
  |               | flex-imx8mm |                 |
  | QEMU          | qemu8       | Qemuv8          |
  | QEMU          | qemu        | Qemuv7          |

- After build is finished, you can run find the raw image ready for flashing to the SD card in `shared/images/`
- Flash raw image to your SD card using [balena etcher](https://www.balena.io/etcher/)
- Insert SD to your DK2 board and boot it
- When Linux is booted, login with root without password.

## Running OPTEE tests

When your target is booted you can verify that everything works as expected
by using OP-TEE sanity test suit.

```shell
$ xtest
...
regression_8001 OK
regression_8002 OK
regression_8101 OK
regression_8102 OK
regression_8103 OK
+-----------------------------------------------------
24603 subtests of which 0 failed
99 test cases of which 0 failed
0 test cases were skipped
TEE test application done!
```

Also you can invoke minimal Rust TEE "hello world" application:

```shell
 root@qemu-optee32:~# hello_rustee
    [RUSTEE] <= 12345
    [RUSTEE] => 12387
```
