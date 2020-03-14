DOCKER_IMAGE="zondax/builder-yocto"
RUSTEE_APP_LOCAL="/home/xdev/zondax/reps/hello-rustee.git"

INTERACTIVE:=$(shell [ -t 0 ] && echo 1)

ifdef INTERACTIVE
INTERACTIVE_SETTING:="-i"
TTY_SETTING:="-t"
else
INTERACTIVE_SETTING:=
TTY_SETTING:=
endif

define run_docker
	docker run $(TTY_SETTING) $(INTERACTIVE_SETTING) --rm \
	--privileged \
	-u $(shell id -u) \
	-v $(shell pwd)/shared:/home/zondax/shared \
	-v $(RUSTEE_APP_LOCAL):/home/zondax/hello-rustee.git \
	-p 8000:8000	\
	-e DISPLAY=$(shell echo ${DISPLAY}) \
	-e ZONDAX_CONF=$(2) \
	-v /tmp/.X11-unix:/tmp/.X11-unix:ro \
	$(DOCKER_IMAGE) \
	"$(1)"
endef

pull_docker:
	docker pull $(DOCKER_IMAGE)

login: pull_docker
	$(call run_docker,zsh)

shell_bytesatwork: pull_docker
	$(call run_docker,/home/zondax/shared/zxshell.sh,bytesatwork)

shell_dk2: pull_docker
	$(call run_docker,/home/zondax/shared/zxshell.sh,dk2)

shell_imx8mq: pull_docker
	$(call run_docker,/home/zondax/shared/zxshell.sh,imx8mq)

toaster: pull_docker
	$(call run_docker,/home/zondax/shared/zxtoaster.sh,dk2)

build_image_bytesatwork: pull_docker
	$(call run_docker,/home/zondax/shared/zxbuild.sh,bytesatwork)

build_image_dk2: pull_docker
	$(call run_docker,/home/zondax/shared/zxbuild.sh,dk2)

build_image_imx8mq: pull_docker
	$(call run_docker,/home/zondax/shared/zxbuild.sh,imx8mq)
