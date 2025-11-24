ARG APCU_VERSION

ARG PHP_EXT_BASE_IMAGE=scratch
ARG PHP_BASE_IMAGE=scratch

FROM --platform=$BUILDPLATFORM ${PHP_EXT_BASE_IMAGE} AS php-ext-apcu-build
ARG TARGETARCH
ARG BUILDARCH

ARG APCU_VERSION
RUN mkdir -p /usr/src/php/ext \
    && cd /usr/src/php/ext \
    && curl -sfL -o apcu-${APCU_VERSION}.tgz https://pecl.php.net/get/apcu-${APCU_VERSION}.tgz \
    && tar -xzf apcu-${APCU_VERSION}.tgz \
    && rm apcu-${APCU_VERSION}.tgz \
    && mv apcu-${APCU_VERSION} apcu

RUN cd /usr/src/php/ext/apcu \
    && phpize \
    && ./configure \
        --build `echo ${BUILDARCH} | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#'`-none-linux \
        --host `echo ${TARGETARCH} | sed  -e 's#arm64#aarch64#' -e 's#amd64#x86_64#'`-none-linux \
        `[ "${TARGETARCH}" != "${BUILDARCH}" ] \
            && echo CC=${TARGETARCH}-linux-gnu-gcc-12 | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#' \
            && echo CXX=${TARGETARCH}-linux-gnu-g++-12 | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#' \
            && echo PKG_CONFIG=/usr/bin/${TARGETARCH}-linux-gnu-pkg-config | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#' \
        ` \
    && make -j$(nproc) \
    && make install

RUN mkdir -p /install/php-ext \
        /install/usr/local/lib/php/doc/php-pecl-apc-${APCU_VERSION} \
        /install/usr/local/include/php/ext/ \
        /install/usr/local/share/doc/php-acpu \
    && ( \
        echo '#!/bin/bash' \
        && echo 'set -e -o pipefail' \
        && echo \
        && echo 'if php -m | grep -q "^apcu$"; then' \
        && echo '  echo "apcu already active"' \
        && echo '  exit 1' \
        && echo 'fi' \
        && echo \
        && echo 'cd "$(dirname "${BASH_SOURCE[0]}")"' \
        && echo \
        && echo '# Install apcu extension' \
        && echo 'cp php-ext/* /usr/local/lib/php/extensions/*/' \
        && echo 'cp -rP usr/* /usr/' \
        && echo 'docker-php-ext-enable apcu' \
        && echo 'php -m | grep -q "^apcu$"' \
    ) > /install/install.sh \
    && chmod +x /install/install.sh \
    && cp /usr/local/lib/php/extensions/*/apcu.so \
        /install/php-ext/ \
    && cp /usr/src/php/ext/apcu/apc.php \
        /install/usr/local/lib/php/doc/php-pecl-apc-${APCU_VERSION}/ \
    && cp -rP /usr/local/include/php/ext/apcu \
        /install/usr/local/include/php/ext/ \
    && cp /usr/src/php/ext/apcu/LICENSE \
        /install/usr/local/share/doc/php-acpu/copyright

FROM scratch AS php-ext-apcu
COPY --from=php-ext-apcu-build /install /

FROM ${PHP_BASE_IMAGE} AS php-ext-apcu-test
RUN --mount=type=cache,target=/var/cache/apt,sharing=private \
    --mount=type=cache,target=/var/lib/apt,sharing=private \
    --mount=type=bind,from=php-ext-apcu,target=/usr/src/php-ext-apcu \
    /usr/src/php-ext-apcu/install.sh

RUN --mount=type=bind,from=php-ext-apcu-build,source=/usr/src/php,target=/src/php,rw \
    mkdir -p /usr/src/php/ext \
    && cp -r /src/php/ext/apcu /usr/src/php/ext/apcu \
    && cd /usr/src/php/ext/apcu \
    && sed -i 's#test: all#test:#' Makefile \
    && rm -rf .libs modules \
    && mkdir modules \
    && ln -s "$(php-config --extension-dir)/apcu.so" modules/apcu.so \
    && echo '#!/bin/bash' > run.sh \
    && echo 'set -e -o pipefail' >> run.sh \
    && echo 'php run-tests.php -j$(nproc) -q' >> run.sh \
    && chmod +x run.sh

WORKDIR /usr/src/php/ext/apcu
CMD ["./run.sh"]

FROM php-ext-apcu-test AS test

FROM php-ext-apcu AS default
