#!/bin/bash
set -e

DISTRIB_NAME=ubuntu
DISTRIB_VERSION=focal
NEOVIM_VERSION=0.9.1
DEBIAN_VERSION=1
FORCE=0

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --ubuntu) DISTRIB_NAME=ubuntu; DISTRIB_VERSION="$2"; shift ;;
        --debian) DISTRIB_NAME=debian; DISTRIB_VERSION="$2"; shift ;;
        --neovim) NEOVIM_VERSION="$2"; shift ;;
        --package-version) DEBIAN_VERSION="$2"; shift ;;
        --force) FORCE=1 ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

DOCKER_IMAGE_NAME="build-nlz-neovim-${DISTRIB_NAME}-${DISTRIB_VERSION}-${NEOVIM_VERSION}"
TARGET="build/${DISTRIB_NAME}/${DISTRIB_VERSION}/nlz-neovim-${NEOVIM_VERSION}_${DEBIAN_VERSION}_amd64.deb"

cd $(dirname $0)

echo ${FORCE}
if [[ -f ${TARGET} && "${FORCE}" -ne "1" ]]; then
	echo "Already exist ${TARGET}"
	ls -l ${TARGET}
else
	echo "Launch build"
	docker build \
		--load \
		--tag "${DOCKER_IMAGE_NAME}" \
		--build-arg "DISTRIB_NAME=${DISTRIB_NAME}" \
		--build-arg "DISTRIB_VERSION=${DISTRIB_VERSION}" \
		--build-arg "NEOVIM_VERSION=${NEOVIM_VERSION}" \
		--build-arg "DEBIAN_VERSION=${DEBIAN_VERSION}" \
		.
	docker build \
		--tag "${DOCKER_IMAGE_NAME}" \
		--build-arg "DISTRIB_NAME=${DISTRIB_NAME}" \
		--build-arg "DISTRIB_VERSION=${DISTRIB_VERSION}" \
		--build-arg "NEOVIM_VERSION=${NEOVIM_VERSION}" \
		--build-arg "DEBIAN_VERSION=${DEBIAN_VERSION}" \
		--output=build --target=binaries \
		.
fi
