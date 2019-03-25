default: list

DOCKER_IMAGE ?= edofede/baseimage
# COMMENT ?= Automated commit from Makefile

ARCHS ?= amd64 arm32v6 arm32v7 i386 ppc64le s390x
ALPINE_BRANCH ?= 3.9.2

GITHUB_TOKEN ?= 

BRANCH ?= devel
VERSION ?= devel
DOCKER_TAG = $(shell echo $(VERSION) |sed 's/^v//')
GIT_COMMIT = $(strip $(shell git rev-parse --short HEAD))
# GIT_URL = $(shell git config --get remote.origin.url)
# BUILD_DATE = $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')

.PHONY: list git_push output build debug run test test_all docker_push docker_push_latest


list:
	@printf "# Available targets: \\n"
	@cat Makefile |sed '1d' |cut -d ' ' -f1 |grep : |grep -v -e '\t' -e '\.' |cut -d ':' -f1


git_push:
ifndef COMMENT
	@printf "Add comment to current commit: \\nSyntax: make git_push COMMENT=\"xxxx\"\\n"
else
	git add .
	git commit -S -m "$(COMMENT)"
	git push origin $(BRANCH)
endif


output:
	@echo Docker Image: "$(DOCKER_IMAGE)":"$(DOCKER_TAG)"


build:
	@$(foreach ARCH,$(ARCHS), \
		scripts/build.sh -i $(DOCKER_IMAGE) -t $(DOCKER_TAG) \
			-a $(ARCH) \
			-b $(ALPINE_BRANCH) \
			-v $(VERSION) \
			-r $(GIT_COMMIT) ;\
	)
	

run:
	@docker run --rm \
		$(DOCKER_IMAGE):$(DOCKER_TAG) &


debug:
	@docker run --rm -ti \
		$(DOCKER_IMAGE):$(DOCKER_TAG) \
		/bin/bash


test:
	@./scripts/testSyslog.sh $(DOCKER_TAG)


test_all:
	@$(foreach ARCH,$(ARCHS), \
		./scripts/testSyslog.sh $(DOCKER_TAG)-$(ARCH); \
	)


docker_push:
	@./scripts/pushDockerHub.sh -i $(DOCKER_IMAGE) -t $(DOCKER_TAG)


docker_push_latest:
	@./scripts/pushDockerHub.sh -i $(DOCKER_IMAGE) -t $(DOCKER_TAG) -l





# clean_qemu:
# 	rm -rf build_tmp/


# get_qemu: clean_qemu
# 	rm -rf build_tmp/
# 	mkdir -p build_tmp/qemu

# ifdef GITHUB_TOKEN
# 	QEMU_RELEASE = $(shell curl -u EdoFede:$(GITHUB_TOKEN) --silent --connect-timeout 5 --max-time 10 --retry 5 --retry-delay 1 --retry-max-time 60 "https://api.github.com/repos/multiarch/qemu-user-static/releases/latest" |grep '"tag_name":' |sed -E 's/.*"([^"]+)".*/\1/')
# else
# 	QEMU_RELEASE = $(shell curl --silent --connect-timeout 5 --max-time 10 --retry 5 --retry-delay 1 --retry-max-time 60 "https://api.github.com/repos/multiarch/qemu-user-static/releases/latest" |grep '"tag_name":' |sed -E 's/.*"([^"]+)".*/\1/')
# endif
# ifndef QEMU_RELEASE
# 	QEMU_RELEASE = "v3.0.0"
# endif

# 	$(foreach QEMU_ARCH,$(QEMU_ARCHS), \
# 		set -e ;\
# 		curl -L \
# 			--connect-timeout 5 \
# 			--max-time 10 \
# 			--retry 5 \
# 			--retry-delay 0 \
# 			--retry-max-time 60 \
# 			https://github.com/multiarch/qemu-user-static/releases/download/$(QEMU_RELEASE)/qemu-$(QEMU_ARCH)-static.tar.gz \
# 			-o build_tmp/qemu-$(QEMU_ARCH)-static.tar.gz; \
# 		tar zxvf \
# 			build_tmp/qemu-*-static.tar.gz \
# 			-C build_tmp/qemu/
# 	)


# build: get_qemu
# 	$(foreach ARCH,$(ARCHS), \
# 		@docker build \
# 			--build-arg ARCH=$(ARCH) \
# 			--build-arg ALPINE_BRANCH=$(ALPINE_BRANCH) \
# 			--build-arg BUILD_DATE=$(BUILD_DATE) \
# 			--build-arg VERSION=$(VERSION) \
# 			--build-arg VCS_REF=$(GIT_COMMIT) \
# 			--tag $(DOCKER_IMAGE):$(DOCKER_TAG)-$(ARCH) \
# 			.
# 	)
# 	make clean_qemu




# manifest:
# 	@docker manifest create --amend $(DOCKER_IMAGE):$(DOCKER_TAG) \
# 		$(DOCKER_IMAGE):amd64-$(DOCKER_TAG) \
# 		$(DOCKER_IMAGE):arm32v6-$(DOCKER_TAG) \
# 		$(DOCKER_IMAGE):arm32v7-$(DOCKER_TAG)
# 	@docker manifest annotate $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):amd64-$(DOCKER_TAG) --os linux --arch amd64
# 	@docker manifest annotate $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):arm32v6-$(DOCKER_TAG) --os linux --arch arm --variant armv6
# 	@docker manifest annotate $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):arm32v7-$(DOCKER_TAG) --os linux --arch arm --variant armv7
# 	# @docker manifest annotate $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):arm64v8-$(DOCKER_TAG) --os linux --arch arm64 --variant armv8
# 	# @docker manifest annotate $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):i386-$(DOCKER_TAG) --os linux --arch x86
# 	@docker manifest push --purge $(DOCKER_IMAGE):$(DOCKER_TAG)

# manifest_latest:
# 	@docker manifest create --amend $(DOCKER_IMAGE):latest \
# 		$(DOCKER_IMAGE):amd64-$(DOCKER_TAG) \
# 		$(DOCKER_IMAGE):arm32v6-$(DOCKER_TAG) \
# 		$(DOCKER_IMAGE):arm32v7-$(DOCKER_TAG)
# 	@docker manifest annotate $(DOCKER_IMAGE):latest $(DOCKER_IMAGE):amd64-$(DOCKER_TAG) --os linux --arch amd64
# 	@docker manifest annotate $(DOCKER_IMAGE):latest $(DOCKER_IMAGE):arm32v6-$(DOCKER_TAG) --os linux --arch arm --variant armv6
# 	@docker manifest annotate $(DOCKER_IMAGE):latest $(DOCKER_IMAGE):arm32v7-$(DOCKER_TAG) --os linux --arch arm --variant armv7
# 	# @docker manifest annotate $(DOCKER_IMAGE):latest $(DOCKER_IMAGE):arm64v8-$(DOCKER_TAG) --os linux --arch arm64 --variant armv8
# 	# @docker manifest annotate $(DOCKER_IMAGE):latest $(DOCKER_IMAGE):i386-$(DOCKER_TAG) --os linux --arch x86
# 	@docker manifest push --purge $(DOCKER_IMAGE):latest

# push_docker:
# 	@docker push $(DOCKER_IMAGE):amd64-$(DOCKER_TAG)
# 	@docker push $(DOCKER_IMAGE):arm32v6-$(DOCKER_TAG)
# 	@docker push $(DOCKER_IMAGE):arm32v7-$(DOCKER_TAG)
# 	# docker push $(DOCKER_IMAGE):arm64v8-$(DOCKER_TAG)
# 	# docker push $(DOCKER_IMAGE):i386-$(DOCKER_TAG)


# push_docker_latest:
# 	@docker tag $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):latest
# 	@docker push $(DOCKER_IMAGE):latest






