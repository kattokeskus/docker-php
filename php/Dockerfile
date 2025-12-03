# This image contains targets for PHP base images
#
# 1. base: Base PHP image
#   - PHP_VARIANT: PHP variant to use, default bookworm
#   - PHP_VERSION: PHP version to use, default 8
#   - PHP_BASE_IMAGE: (optional) default=docker.io/library/php:${PHP_VERSION}-${PHP_VARIANT}
# 2. extension-build-base: Base image for building PHP extensions
#   - PHP_VARIANT: PHP variant to use, default bookworm
#   - PHP_VERSION: PHP version to use, default 8
#   - PHP_BASE_IMAGE: (optional) default=docker.io/library/php:${PHP_VERSION}-${PHP_VARIANT}
# 3. install-extension: step to install an extension to image
#   - EXTENSION_IMAGE: image containing the extension install script on /install.sh
#   - PHP_BASE_IMAGE: PHP base image to install the extension to
# 4. dummy: step to retag image
#   - IMAGE: image to retag

ARG PHP_VARIANT=bookworm
ARG PHP_VERSION=8

ARG PHP_BASE_IMAGE=docker.io/library/php:${PHP_VERSION}-${PHP_VARIANT}
ARG EXTENSION_IMAGE=scratch
ARG IMAGE=scratch

##############
# Base image #
##############
FROM ${PHP_BASE_IMAGE} AS base

ENV OPENSSL_CONF=/etc/ssl

##############################
# Extension build base image #
##############################
FROM ${PHP_BASE_IMAGE} AS extension-build-base
ARG TARGETARCH

ENV OPENSSL_CONF=/etc/ssl

# Add target architecture
RUN dpkg --add-architecture $([ "${TARGETARCH}" = "amd64" ] && echo "arm64" || echo "amd64")

# Install common build dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install -y -qq \
        pkgconf:amd64 \
        pkgconf:arm64 \
        g++ \
        $(echo g++-12-${TARGETARCH}-linux-gnu | sed -e 's#arm64#x86-64#' -e 's#amd64#aarch64#')

# Extract extension source
RUN docker-php-source extract

##########################
# Extension source alias #
##########################
FROM ${EXTENSION_IMAGE} AS extension-source

##########################
# Install extension step #
##########################
FROM ${PHP_BASE_IMAGE} AS install-extension
RUN --mount=type=bind,from=extension-source,target=/ext \
    /ext/install.sh

###############
# Dummy image #
###############
FROM ${IMAGE} AS dummy

#################
# Default image #
#################
FROM base AS default
