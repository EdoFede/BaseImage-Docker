#!/bin/bash
set -e

source scripts/multiArchMatrix.sh

showHelp() {
	echo "Usage: $0 -i <image name> -t <tag name> -a <target arch> -b <alpine linux branch> -v <version> -r <vcs reference> -g <github token>"
}

while getopts :hi:t:a:b:v:r:g: opt; do
	case ${opt} in
		h)
			showHelp
			exit 0
			;;
		i)
			DOCKER_IMAGE=$OPTARG
			;;
		t)
			DOCKER_TAG=$OPTARG
			;;
		a)
			ARCH=$OPTARG
			;;
		b)
			ALPINE_BRANCH=$OPTARG
			;;
		v)
			VERSION=$OPTARG
			;;
		r)
			VCS_REF=$OPTARG
			;;
		g)
			GITHUB_TOKEN=$OPTARG
			;;
		\?)
			echo "Invalid option: $OPTARG" 1>&2
			showHelp
			exit 1
			;;
		:)
			echo "Invalid option: $OPTARG requires an argument" 1>&2
			showHelp
			exit 1
			;;
		*)
			showHelp
			exit 0
			;;
	esac
done
shift "$((OPTIND-1))"

printf "\\n### Building image ###\\n"
printf "Docker image: $DOCKER_IMAGE\\n"
printf "Docker tag: $DOCKER_TAG\\n"

printf "Architecture: $ARCH\\n"
printf "Alpine branch: $ALPINE_BRANCH\\n"
printf "Image version: $VERSION\\n"
printf "VCS reference: $VCS_REF\\n"

rm -rf build_tmp/
mkdir -p build_tmp/qemu

if [[ -z GITHUB_TOKEN ]]; then
	QEMU_RELEASE=$(curl --silent --connect-timeout 5 --max-time 10 --retry 5 --retry-delay 1 --retry-max-time 60 "https://api.github.com/repos/multiarch/qemu-user-static/releases/latest" |grep '"tag_name":' |sed -E 's/.*"([^"]+)".*/\1/')
else
	QEMU_RELEASE=$(curl -u EdoFede:$GITHUB_TOKEN --silent --connect-timeout 5 --max-time 10 --retry 5 --retry-delay 1 --retry-max-time 60 "https://api.github.com/repos/multiarch/qemu-user-static/releases/latest" |grep '"tag_name":' |sed -E 's/.*"([^"]+)".*/\1/')	
fi

if [[ -z QEMU_RELEASE ]]; then
	QEMU_RELEASE="v3.0.0"
fi

for i in ${!ARCHS[@]}; do
	if [[ "${ARCHS[i]}" == "$ARCH" ]]; then
		QEMU_ARCH=${QEMU_ARCHS[i]}
		break
	fi
done

if [[ "$QEMU_ARCH" != "NONE" ]]; then
	curl -L \
		--connect-timeout 5 \
		--max-time 10 \
		--retry 5 \
		--retry-delay 0 \
		--retry-max-time 60 \
		https://github.com/multiarch/qemu-user-static/releases/download/$QEMU_RELEASE/qemu-$QEMU_ARCH-static.tar.gz \
		-o build_tmp/qemu-$QEMU_ARCH-static.tar.gz && \
	tar zxvf \
		build_tmp/qemu-*-static.tar.gz \
		-C build_tmp/qemu/
fi


BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')

docker build \
	--build-arg ARCH=$ARCH \
	--build-arg ALPINE_BRANCH=$ALPINE_BRANCH \
	--build-arg BUILD_DATE=$BUILD_DATE \
	--build-arg VERSION=$VERSION \
	--build-arg VCS_REF=$VCS_REF \
	--tag $DOCKER_IMAGE:$DOCKER_TAG-$ARCH \
	.

rm -rf build_tmp/
