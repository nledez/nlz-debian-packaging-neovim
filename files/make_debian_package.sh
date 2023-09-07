#!/bin/bash

DISTRIB_NAME="${1}"
DISTRIB_VERSION="${2}"
NEOVIM_VERSION="${3}"
DEBIAN_VERSION="${4}"

BASE_PATH="/target"
DEBIAN_BASE_PATH="${BASE_PATH}/nlz-neovim-${NEOVIM_VERSION}-${DEBIAN_VERSION}_amd64"

export EMAIL"=github@ledez.net"
export NAME="Nicolas Ledez"
export EDITOR=/bin/true

mkdir -p "${DEBIAN_BASE_PATH}/debian"

cd "${BASE_PATH}"
sed -i "s/%NEOVIM_VERSION%/${NEOVIM_VERSION}/" debian/control debian/rules
cat debian/control
mv debian "${DEBIAN_BASE_PATH}"
cd "${DEBIAN_BASE_PATH}"
dch --create --empty --distribution "${DISTRIB_VERSION}" --package nlz-neovim-${NEOVIM_VERSION} -v "${DEBIAN_VERSION}"
cat debian/changelog

debuild --no-tgz-check --no-lintian -i -us -uc -b
find ${DEBIAN_BASE_PATH}

ls -l ${BASE_PATH}

DELIVERY_PATH="/build/${DISTRIB_NAME}/${DISTRIB_VERSION}/"
test -d "${DELIVERY_PATH}" || mkdir -p "${DELIVERY_PATH}"
ls "${BASE_PATH}"
mv ${BASE_PATH}/*.deb "${DELIVERY_PATH}"
