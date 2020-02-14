DOCKER_IMAGE="zondax/docker-stm32-optee"

define run_docker
	docker run -it --rm \
	--privileged \
	-u $(shell id -u) \
	-v $(shell pwd)/shared:/home/zondax/shared \
	-e DISPLAY=$(shell echo ${DISPLAY}) \
	-v /tmp/.X11-unix:/tmp/.X11-unix:ro \
	$(DOCKER_IMAGE) \
	"$(1)"
endef

build_image:
	# TODO: Launch a script to automate all the work
	docker build --rm -f Dockerfile -t $(DOCKER_IMAGE) .

build_docker:
	docker build --rm -f Dockerfile -t $(DOCKER_IMAGE) .

publish_docker:
	docker login
	docker build --rm -f Dockerfile -t $(DOCKER_IMAGE) .
	docker push $(DOCKER_IMAGE)

pull_docker:
	docker pull $(DOCKER_IMAGE)

shell:
	$(call run_docker,zsh)
