# syntax=docker/dockerfile:1
ARG DISTRIB_NAME=ubuntu
ARG DISTRIB_VERSION=focal

FROM ${DISTRIB_NAME}:${DISTRIB_VERSION} AS build

ENV DEBIAN_FRONTEND=noninteractive

ARG DISTRIB_NAME=ubuntu
ARG DISTRIB_VERSION=focal
ARG NEOVIM_VERSION=0.9.1
ARG DEBIAN_VERSION=1

USER root

RUN apt-get update && \
    apt-get install --no-install-recommends -q -y \
    build-essential \
    debhelper \
    devscripts \
    ca-certificates \
    libdistro-info-perl \
    curl \
    git \
    cmake \
    ninja-build \
    gettext \
    unzip

RUN --mount=type=cache,target=/neovim \
    curl -s -L -o /neovim/Neovim-${NEOVIM_VERSION}.tgz https://github.com/neovim/neovim/archive/refs/tags/v${NEOVIM_VERSION}.tar.gz && \
    tar xzf /neovim/Neovim-${NEOVIM_VERSION}.tgz

RUN cd /neovim-${NEOVIM_VERSION}/ && \
    make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/opt/neovim" install

COPY ./debian /target/debian
COPY ./files/make_debian_package.sh /make_debian_package.sh

RUN /make_debian_package.sh "${DISTRIB_NAME}" "${DISTRIB_VERSION}" "${NEOVIM_VERSION}" "${DEBIAN_VERSION}"

FROM scratch AS binaries
COPY --from=build /build /

# vim: tabstop=4 shiftwidth=4 expandtab filetype=dockerfile
