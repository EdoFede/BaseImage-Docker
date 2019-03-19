default: list

ARCH ?= amd64
QEMU_RELEASE ?= v3.1.0-2

ALPINE_BRANCH ?= 3.9.2
DOCKER_IMAGE ?= edofede/baseimage
COMMENT ?= Automated push from Makefile

VERSION  = $(strip $(shell [ -f VERSION ] && head VERSION || echo '0.1'))
DOCKER_TAG = $(shell echo $(VERSION) |sed 's/^.//')
GIT_COMMIT = $(strip $(shell git rev-parse --short HEAD))
GIT_URL = $(shell git config --get remote.origin.url)


.PHONY: list clean_qemu get_qemu build_arch build debug run output commit push_master push_tagged


list:
	@printf "Targets:\\n"
	@grep '^[^#[:space:]].*:' Makefile |cut -d ':' -f1 |sed -n '1!p'


clean_qemu:
	rm -rf build_tmp/


get_qemu: clean_qemu
	mkdir -p build_tmp/qemu

ifeq ($(ARCH),amd64)
endif

ifeq ($(ARCH),arm32v6)
	set -e ;\
	QEMU_ARCH="arm"; \
	curl -L \
		--connect-timeout 5 \
		--max-time 10 \
		--retry 5 \
		--retry-delay 0 \
		--retry-max-time 60 \
		https://github.com/multiarch/qemu-user-static/releases/download/$(QEMU_RELEASE)/qemu-$$QEMU_ARCH-static.tar.gz \
		-o build_tmp/qemu-arm-static.tar.gz; \
	tar zxvf \
		build_tmp/qemu-*-static.tar.gz \
		-C build_tmp/qemu/
endif

ifeq ($(ARCH),arm32v7)
	set -e ;\
	QEMU_ARCH="arm"; \
	curl -L \
		--connect-timeout 5 \
		--max-time 10 \
		--retry 5 \
		--retry-delay 0 \
		--retry-max-time 60 \
		https://github.com/multiarch/qemu-user-static/releases/download/$(QEMU_RELEASE)/qemu-$$QEMU_ARCH-static.tar.gz \
		-o build_tmp/qemu-arm-static.tar.gz; \
	tar zxvf \
		build_tmp/qemu-*-static.tar.gz \
		-C build_tmp/qemu/
endif

ifeq ($(ARCH),arm64v8)
	set -e ;\
	QEMU_ARCH="aarch64"; \
	curl -L \
		--connect-timeout 5 \
		--max-time 10 \
		--retry 5 \
		--retry-delay 0 \
		--retry-max-time 60 \
		https://github.com/multiarch/qemu-user-static/releases/download/$(QEMU_RELEASE)/qemu-$$QEMU_ARCH-static.tar.gz \
		-o build_tmp/qemu-arm-static.tar.gz; \
	tar zxvf \
		build_tmp/qemu-*-static.tar.gz \
		-C build_tmp/qemu/
endif

ifeq ($(ARCH),i386)
	set -e ;\
	QEMU_ARCH="i386"; \
	curl -L \
		--connect-timeout 5 \
		--max-time 10 \
		--retry 5 \
		--retry-delay 0 \
		--retry-max-time 60 \
		https://github.com/multiarch/qemu-user-static/releases/download/$(QEMU_RELEASE)/qemu-$$QEMU_ARCH-static.tar.gz \
		-o build_tmp/qemu-arm-static.tar.gz; \
	tar zxvf \
		build_tmp/qemu-*-static.tar.gz \
		-C build_tmp/qemu/
endif


build_arch: get_qemu
	@docker build \
		--build-arg ARCH=$(ARCH) \
		--build-arg ALPINE_BRANCH=$(ALPINE_BRANCH) \
		--build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
		--build-arg VERSION=$(VERSION) \
		--build-arg VCS_REF=$(GIT_COMMIT) \
		--tag $(DOCKER_IMAGE):$(ARCH)-$(DOCKER_TAG) \
		.


build: 
	$(MAKE) build_arch
	$(MAKE) clean_qemu


debug:
	docker run --rm -ti \
		$(DOCKER_IMAGE):$(ARCH)-$(DOCKER_TAG) \
		/bin/bash


run:
	docker run --rm \
		$(DOCKER_IMAGE):$(ARCH)-$(DOCKER_TAG) &


manifest:
	docker manifest create --amend $(DOCKER_IMAGE):$(DOCKER_TAG) \
		$(DOCKER_IMAGE):amd64-$(DOCKER_TAG) \
		$(DOCKER_IMAGE):arm32v6-$(DOCKER_TAG) \
		$(DOCKER_IMAGE):arm32v7-$(DOCKER_TAG)
	docker manifest annotate $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):amd64-$(DOCKER_TAG) --os linux --arch amd64
	docker manifest annotate $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):arm32v6-$(DOCKER_TAG) --os linux --arch arm --variant armv6
	docker manifest annotate $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):arm32v7-$(DOCKER_TAG) --os linux --arch arm --variant armv7
	# docker manifest annotate $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):arm64v8-$(DOCKER_TAG) --os linux --arch arm64 --variant armv8
	# docker manifest annotate $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):i386-$(DOCKER_TAG) --os linux --arch x86
	docker manifest push --purge $(DOCKER_IMAGE):$(DOCKER_TAG)


push_docker:
	docker push $(DOCKER_IMAGE):amd64-$(DOCKER_TAG)
	docker push $(DOCKER_IMAGE):arm32v6-$(DOCKER_TAG)
	docker push $(DOCKER_IMAGE):arm32v7-$(DOCKER_TAG)
	# docker push $(DOCKER_IMAGE):arm64v8-$(DOCKER_TAG)
	# docker push $(DOCKER_IMAGE):i386-$(DOCKER_TAG)


push_latest:
	docker tag $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):latest
	docker push $(DOCKER_IMAGE):latest


output:
	@echo Docker Image: "$(DOCKER_IMAGE)":"$(ARCH)"-"$(DOCKER_TAG)"


commit:
	git add .
	git commit -S -m "$(COMMENT)"


push_master:
	git push origin


push_tagged:
	git tag -s -a -m "$(COMMENT)" "$(VERSION)"
	git push origin "$(VERSION)"
