# ARM-TEE-Image

- `make build` to build the container image
- `make pull` to retrieve the latest published container image
- `make shell` to login into the container

the shared directory can be used to exchange information with the build container.

Once inside the container:
```
cd shared
./setup_stm.sh
```

This will give you a bash session with environment ready to start:

```
bitbake st-image-weston
bitbake optee-os-stm32mp        # OP-TEE core firmware
bitbake optee-client            # OP-TEE client
bitbake optee-test              # OP-TEE test suite (optional)
bitbake optee-examples
```
