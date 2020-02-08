#!/usr/bin/env bash

# ENV TAG_NAME openstlinux-4.19-thud-mp1-19-10-09
# RUN mkdir -p /home/zondax/${TAG_NAME} && cd /home/zondax/${TAG_NAME}
# WORKDIR /home/zondax/${TAG_NAME}

# RUN repo init -u https://github.com/STMicroelectronics/oe-manifest.git -b refs/tags/${TAG_NAME}
# RUN repo sync

# export DISTRO=openstlinux-weston 
# export MACHINE=stm32mp1
# export 

# source layers/meta-st/scripts/envsetup.sh

# # bitbake st-image-weston
# # bitbake optee-os-stm32mp                # OP-TEE core firmware
# # bitbake optee-client                    # OP-TEE client
# # bitbake optee-test                      # OP-TEE test suite (optional)
# # bitbake optee-examples
