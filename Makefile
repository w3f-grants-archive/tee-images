DOCKER_IMAGE="zondax/builder-yocto"

INTERACTIVE:=$(shell [ -t 0 ] && echo 1)

ifdef INTERACTIVE
INTERACTIVE_SETTING:="-i"
TTY_SETTING:="-t"
else
INTERACTIVE_SETTING:=
TTY_SETTING:=
endif

SCRIPTS_DIR=/home/zondax/shared/scripts

QEMU_SERIAL1 := 54320
QEMU_SERIAL2 := 54321
GDB_SERVER := 1234

gnome-terminal := $(shell command -v gnome-terminal 2>/dev/null)
xterm := $(shell command -v xterm 2>/dev/null)
ifdef gnome-terminal
define launch-terminal
	$(gnome-terminal) -x telnet localhost $(1) &
endef
else
ifdef xterm
define launch-terminal
	$(xterm) -title $(2) -e $(BASH) -c "telnet localhost $(1)"
endef
endif
endif

# $(2) is MACHINE
define run_docker_build
	docker run $(TTY_SETTING) $(INTERACTIVE_SETTING) --rm \
	-u $(shell id -u) \
	-v $(shell pwd)/shared:/home/zondax/shared \
	-p $(QDB_SERVER):$(GDB_SERVER) \
	-e ZONDAX_CONF=$(2) \
	$(DOCKER_IMAGE) \
	"$(1)"
endef

define run_docker_qemu
	docker run $(TTY_SETTING) $(INTERACTIVE_SETTING) --rm \
	-u $(shell id -u) \
	-v $(shell pwd)/shared:/home/zondax/shared \
	-p $(QEMU_SERIAL1):$(QEMU_SERIAL1) \
	-p $(QEMU_SERIAL2):$(QEMU_SERIAL2) \
	-p $(QDB_SERVER):$(GDB_SERVER) \
	-e ZONDAX_CONF=$(2) \
	$(DOCKER_IMAGE) \
	"$(1)"
endef

define run_docker_qemu_xterm
	$(call launch-terminal,$(QEMU_SERIAL1),"Normal World")
	$(call launch-terminal,$(QEMU_SERIAL2),"Secure World")
	$(call run_docker_qemu,$(1),$(2))
endef

# $(2) is MACHINE
define run_docker_toaster
	docker run $(TTY_SETTING) $(INTERACTIVE_SETTING) --rm \
	-u $(shell id -u) \
	-v $(shell pwd)/shared:/home/zondax/shared \
	-p 8000:8000	\
	-e DISPLAY=$(shell echo ${DISPLAY}) \
	-v /tmp/.X11-unix:/tmp/.X11-unix:ro \
	-e ZONDAX_CONF=$(2) \
	$(DOCKER_IMAGE) \
	"$(1)"
endef

define run_docker_recipe
	$(eval MACHINE := $(word 1, $(2)))
	$(eval RECIPE := $(word 2, $(2)))
	docker run $(TTY_SETTING) $(INTERACTIVE_SETTING) --rm \
	-u $(shell id -u) \
	-v $(shell pwd)/shared:/home/zondax/shared \
	-e ZONDAX_CONF=$(MACHINE) \
	-e ZONDAX_RECIPE=$(RECIPE) \
	$(DOCKER_IMAGE) \
	"$(1)"
endef

.PHONY: help
help:
	@echo "Usage:"
	@echo "   make workspace <target> <recipe>  Create a workspace for <target> <recipe>"
	@echo "   make dev                          Launch a tmux ready environment for QEMU"
	@echo ""
	@echo "Others:"
	@echo "   make docker                       Fetch Zondax docker image"
	@echo "   make manifest                     Fetch Zondax repo manifest"
	@echo "   make login                        Simply login into docker container"
	@echo "   make toaster <target>             Run Toaster web interface"
	@echo "   make build <target>               Build image for <target>"
	@echo "   make shell <target>               Get shell for <target>"
	@echo "   make workspace <target> <recipe>  Create a workspace for <recipe>"
	@echo "   make run <qemu|qemu8>             Run QEMU ARMv7/QEMU ARMv8 emulation"
	@echo "   make run-term <qemu|qemu8>        Run QEMU emulation + fork xterm terminals for NW/SW consoles"
	@echo ""
	@echo "Typical <targets> = qemu qemu8 dk2"
	@echo ""

.PHONY: docker
docker:
	docker pull $(DOCKER_IMAGE)

.PHONY: manifest
manifest: docker
	$(call run_docker_build,$(SCRIPTS_DIR)/zxfetch.sh,null)

.PHONY: login
login: manifest
	$(call run_docker_build,zsh)

.PHONY: toaster
toaster: manifest
	$(call run_docker_toaster,$(SCRIPTS_DIR)/zxtoaster.sh,$(filter-out $@,$(MAKECMDGOALS)))

.PHONY: shell
shell: manifest
	$(call run_docker_build,$(SCRIPTS_DIR)/zxshell.sh,$(filter-out $@,$(MAKECMDGOALS)))

# Building images
.PHONY: build
build: manifest
	$(call run_docker_build,$(SCRIPTS_DIR)/zxbuild.sh,$(filter-out $@,$(MAKECMDGOALS)))

.PHONY: run
run: manifest
	$(call run_docker_qemu,$(SCRIPTS_DIR)/zxrun.sh,$(filter-out $@,$(MAKECMDGOALS)))

.PHONY: run-term
run-term: manifest
	$(call run_docker_qemu_xterm,$(SCRIPTS_DIR)/zxrun.sh,$(filter-out $@,$(MAKECMDGOALS)))

# Creating workspace so you can work locally on recipe source code
# Example:
# $ make workspace target <recipe-name>
.PHONY: workspace
workspace: manifest
	# TODO: We need to improve this
	$(call run_docker_recipe,$(SCRIPTS_DIR)/zxworkspace.sh,$(filter-out $@,$(MAKECMDGOALS)))
	ln -s shared/zondbox-distro/build/workspace/sources sources

.PHONY: dev
dev: 
	# TODO: We need to handle previous sessions? Kill or attach? `tmux kill-server`
	# TODO: We need to handle preexisting stale containers?
	# TODO: make scripts and remove all these sleeps
	tmux new-session -s "zondax-dev" -d "make run qemu; bash"
	tmux set -g mouse on
	tmux split-window -p 66 "echo 'Normal world'; sleep 15; telnet localhost 54320"
	tmux split-window -d "echo 'Waiting for QEMU'; sleep 15; make shell qemu"
	tmux split-window -h "echo 'Secure world'; sleep 15; telnet localhost 54321"
	tmux attach-session -d

# Drop other targets
%:
	@:
