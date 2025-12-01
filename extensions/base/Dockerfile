# This image contains targets for building and installing PHP extensions
#
# 1. php-ext-build: step to build an extension
#   - PHP_EXT_BASE_IMAGE: PHP extension base image. When cross compiling, this image should be buildplatform image containing the build tools for the target architecture.
#   - EXTENSION: extension to build
# 2. php-ext: step to install an extension to image
#   - PHP_EXT_BASE_IMAGE: PHP extension base image. When cross compiling, this image should be buildplatform image containing the build tools for the target architecture.
#   - EXTENSION: extension to build
#   - EXTENSION_SCRATCH_IMAGE: (optional) default=scratch
# 3. php-ext-test: step to build image containing the extension and tests
#   - PHP_EXT_BASE_IMAGE: PHP extension base image. When cross compiling, this image should be buildplatform image containing the build tools for the target architecture.
#   - EXTENSION: extension to build
#   - PHP_BASE_IMAGE: PHP base image to install the extension and tests

ARG PHP_BASE_IMAGE=scratch
ARG PHP_EXT_BASE_IMAGE=scratch
ARG EXTENSION_SCRATCH_IMAGE=scratch

########################
# Build extension step #
########################
FROM ${EXTENSION_SCRATCH_IMAGE} AS php-ext-scratch
FROM --platform=$BUILDPLATFORM ${PHP_EXT_BASE_IMAGE} AS php-ext-build
ARG TARGETARCH
ARG BUILDARCH
ARG EXTENSION
ARG BUILDDEPS=
ARG CONFIGURE=
ARG DEPS=
ARG MODULE=${EXTENSION}

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    ([ ! -z "${BUILDDEPS}" ] || exit 0) \
    && apt-get update \
    && apt-get install -y -qq \
        $(for dep in $BUILDDEPS; do echo $dep:${TARGETARCH}; done)

RUN cd /usr/src/php/ext/${EXTENSION} \
    && phpize \
    && ./configure \
        ${CONFIGURE} \
        --build `echo ${BUILDARCH} | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#'`-none-linux \
        --host `echo ${TARGETARCH} | sed  -e 's#arm64#aarch64#' -e 's#amd64#x86_64#'`-none-linux \
        `[ "${TARGETARCH}" != "${BUILDARCH}" ] \
            && echo CC=${TARGETARCH}-linux-gnu-gcc-12 | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#' \
            && echo CXX=${TARGETARCH}-linux-gnu-g++-12 | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#' \
            && echo PKG_CONFIG=/usr/bin/${TARGETARCH}-linux-gnu-pkg-config | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#' \
        ` \
    && make -j$(nproc) \
    && make install

COPY --from=php-ext-scratch / /install/

RUN mkdir -p /install/php-ext \
        /install/usr/local/share/doc/php-${EXTENSION} \
    && MODULE="${MODULE}" \
    && [ ! -z "$MODULE" ] || MODULE="${EXTENSION}" \
    && ( \
        echo '#!/bin/bash' \
        && echo 'set -e -o pipefail' \
        && echo \
        && echo "if php -m | grep -q \"^${MODULE}$\"; then" \
        && echo '  if [ "${REINSTALL:-0}" -eq 1 ]; then' \
        && echo "    echo \"warning: ${MODULE} already active\" >&2" \
        && echo '  else' \
        && echo "    echo \"${MODULE} already active\"" \
        && echo '    exit 1' \
        && echo '  fi' \
        && echo 'fi' \
        && echo \
        && echo 'cd "$(dirname "${BASH_SOURCE[0]}")"' \
        && [ -z "${DEPS}" ] || ( \
            echo '# Install dependencies' \
            && echo "DEPS=\"${DEPS}\"" \
            && echo 'ARCH="$(dpkg --print-architecture)"' \
            && echo 'ARCH="${TARGETARCH:-$ARCH}"' \
            && echo 'deps_installed=1' \
            && echo 'for dep in $DEPS; do' \
            && echo '  if ! dpkg --get-selections | grep -e "^$dep " -e "^$dep:$ARCH " | grep -q "install$"; then' \
            && echo '    deps_installed=0' \
            && echo '    break' \
            && echo '  fi' \
            && echo 'done' \
            && echo 'if [ "$deps_installed" -eq 0 ]; then' \
            && echo '  apt-get update' \
            && echo '  apt-get install -y -qq --no-install-recommends \\' \
            && echo '    $(for dep in $DEPS; do echo $dep:${ARCH}; done)' \
            && echo 'fi' \
            && echo \
        ) \
        && echo \
        && echo "# Install ${EXTENSION} extension" \
        && echo 'cp php-ext/* /usr/local/lib/php/extensions/*/' \
        && echo "docker-php-ext-enable ${EXTENSION}" \
        && echo 'FOUND_MODULE=$(php -m | grep '"'^$MODULE"'$'"' | head -n1)" \
        && echo '[ "$FOUND_MODULE" = "'"$MODULE"'" ] || ( \\' \
        && echo "  php -m \\" \
        && echo "  && echo \"$MODULE extension not active\" >&2 \\" \
        && echo "  && php -m | grep '^$MODULE"'$'"' \\" \
        && echo "  && exit 1 \\" \
        && echo ")" \
    ) >> /install/install.sh \
    && chmod +x /install/install.sh \
    && cp /usr/local/lib/php/extensions/*/${EXTENSION}.so \
        /install/php-ext/ \
    && cp /usr/src/php/LICENSE \
        /install/usr/local/share/doc/php-${EXTENSION}/copyright

###################
# Extension image #
###################
FROM ${EXTENSION_SCRATCH_IMAGE} AS php-ext
ARG EXTENSION
COPY --from=php-ext-build /install /

########################
# Extension test image #
########################
FROM ${PHP_BASE_IMAGE} AS php-ext-test
ARG EXTENSION
RUN --mount=type=cache,target=/var/cache/apt,sharing=private \
    --mount=type=cache,target=/var/lib/apt,sharing=private \
    --mount=type=bind,from=php-ext,target=/usr/src/php-ext \
    REINSTALL=1 /usr/src/php-ext/install.sh

RUN --mount=type=bind,from=php-ext-build,source=/usr/src/php,target=/src/php,rw \
    mkdir -p /usr/src/php/ext \
    && cp -r /src/php/ext/${EXTENSION} /usr/src/php/ext/${EXTENSION} \
    && cp -r /src/php/ext/standard /usr/src/php/ext/standard \
    && cp -r /src/php/ext/dl_test /usr/src/php/ext/dl_test \
    && cp -r /src/php/sapi /usr/src/php/sapi \
    && (echo "${EXTENSION}" | grep -qv "^pdo_" || cp -r /src/php/ext/pdo /usr/src/php/ext/pdo) \
    && cd /usr/src/php/ext/${EXTENSION} \
    && sed -i 's#test: all#test:#' Makefile \
    && rm -rf .libs modules \
    && mkdir modules \
    && ln -s "$(php-config --extension-dir)/${EXTENSION}.so" modules/${EXTENSION}.so \
    && echo '#!/bin/bash' > run.sh \
    && echo 'set -e -o pipefail' >> run.sh \
    && echo 'php run-tests.php -j$(nproc) -q' >> run.sh \
    && chmod +x run.sh

WORKDIR /usr/src/php/ext/${EXTENSION}
CMD ["./run.sh"]

#################
# Default image #
#################
FROM php-ext AS default
