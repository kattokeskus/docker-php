ARG PHP_EXT_BASE_IMAGE=scratch
ARG PHP_BASE_IMAGE=scratch
ARG XHPROF_VERSION

FROM --platform=$BUILDPLATFORM ${PHP_EXT_BASE_IMAGE} AS php-ext-xhprof-build
ARG TARGETARCH
ARG BUILDARCH

ARG XHPROF_VERSION
RUN mkdir -p /usr/src/php/ext \
    && cd /usr/src/php/ext \
    && curl -sfL -o xhprof-${XHPROF_VERSION}.tgz https://pecl.php.net/get/xhprof-${XHPROF_VERSION}.tgz \
    && tar -xzf xhprof-${XHPROF_VERSION}.tgz \
    && mv xhprof-${XHPROF_VERSION} xhprof \
    && rm xhprof-${XHPROF_VERSION}.tgz

RUN cd /usr/src/php/ext/xhprof \
    && cd extension \
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
    && make install \
    && cd .. \
    && cp -r xhprof_html /usr/local/lib/php \
    && cp -r xhprof_lib /usr/local/lib/php

RUN mkdir -p /install/php-ext \
        /install/usr/local/lib/php \
        /install/usr/local/share/doc/php-xhprof \
    && ( \
        echo '#!/bin/bash' \
        && echo 'set -e -o pipefail' \
        && echo \
        && echo 'if php -m | grep -q "^xhprof$"; then' \
        && echo '  echo "xhprof already active"' \
        && echo '  exit 1' \
        && echo 'fi' \
        && echo \
        && echo 'cd "$(dirname "${BASH_SOURCE[0]}")"' \
        && echo \
        && echo '# Install xhprof extension' \
        && echo 'cp php-ext/* /usr/local/lib/php/extensions/*/' \
        && echo 'cp -rP usr/* /usr/' \
        && echo 'docker-php-ext-enable xhprof' \
        && echo 'php -m | grep -q "^xhprof$"' \
    ) > /install/install.sh \
    && chmod +x /install/install.sh \
    && cp /usr/local/lib/php/extensions/*/xhprof.so \
        /install/php-ext/ \
    && cp -rP /usr/local/lib/php/xhprof_* \
        /install/usr/local/lib/php/ \
    && cp /usr/src/php/ext/xhprof/LICENSE \
        /install/usr/local/share/doc/php-xhprof/copyright

FROM scratch AS php-ext-xhprof
COPY --from=php-ext-xhprof-build /install /

FROM ${PHP_BASE_IMAGE} AS php-ext-xhprof-test
RUN --mount=type=cache,target=/var/cache/apt,sharing=private \
    --mount=type=cache,target=/var/lib/apt,sharing=private \
    --mount=type=bind,from=php-ext-xhprof,target=/usr/src/php-ext-xhprof \
    /usr/src/php-ext-xhprof/install.sh

RUN --mount=type=bind,from=php-ext-xhprof-build,source=/usr/src/php,target=/src/php,rw \
    mkdir -p /usr/src/php/ext \
    && cp -r /src/php/ext/xhprof /usr/src/php/ext/xhprof \
    && cd /usr/src/php/ext/xhprof/extension \
    && sed -i 's#test: all#test:#' Makefile \
    && cp .libs/xhprof.lai modules/xhprof.la \
    && echo '#!/bin/bash' > run.sh \
    && echo 'set -e -o pipefail' >> run.sh \
    && echo 'php run-tests.php -j$(nproc) -q' >> run.sh \
    && chmod +x run.sh

WORKDIR /usr/src/php/ext/xhprof/extension
CMD ["./run.sh"]

FROM php-ext-xhprof-test AS test

FROM php-ext-xhprof AS default
