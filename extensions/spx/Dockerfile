ARG PHP_EXT_BASE_IMAGE=scratch
ARG PHP_BASE_IMAGE=scratch
ARG SPX_VERSION

FROM --platform=$BUILDPLATFORM ${PHP_EXT_BASE_IMAGE} AS php-ext-spx-build
ARG TARGETARCH
ARG BUILDARCH

# NOTE! source directory must be exactly php-spx, otherwise tests will fail
ARG SPX_VERSION
RUN apt-get update \
    && apt-get install -y --no-install-recommends zlib1g-dev \
    && mkdir -p /usr/src/php/ext \
    && cd /usr/src/php/ext \
    && curl -sfL -o spx-${SPX_VERSION}.tar.gz https://github.com/NoiseByNorthwest/php-spx/archive/refs/tags/v${SPX_VERSION}.tar.gz \
    && tar -xzf spx-${SPX_VERSION}.tar.gz \
    && mv php-spx-${SPX_VERSION} php-spx \
    && rm spx-${SPX_VERSION}.tar.gz

RUN cd /usr/src/php/ext/php-spx \
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
        /install/usr/local/share/doc/php-spx \
        /install/usr/local/share/misc/php-spx \
    && ( \
        echo '#!/bin/bash' \
        && echo 'set -e -o pipefail' \
        && echo \
        && echo 'if php -m | grep -q "^SPX$"; then' \
        && echo '  echo "spx already active"' \
        && echo '  exit 1' \
        && echo 'fi' \
        && echo \
        && echo 'cd "$(dirname "${BASH_SOURCE[0]}")"' \
        && echo \
        && echo '# Install spx extension' \
        && echo 'cp php-ext/* /usr/local/lib/php/extensions/*/' \
        && echo 'cp -rP usr/* /usr/' \
        && echo 'docker-php-ext-enable spx' \
        && echo 'echo "spx.http_ui_assets_dir=/usr/local/share/misc/php-spx/assets/web-ui" >> $PHP_INI_DIR/conf.d/docker-php-ext-spx.ini' \
        && echo 'FOUND_MODULE=$(php -m | grep "^SPX$" | head -n1)' \
        && echo '[ "$FOUND_MODULE" = "SPX" ] || ( \\' \
        && echo '  php -m \\' \
        && echo '  && echo "spx extension not active" >&2 \\' \
        && echo '  && php -m | grep "^SPX$" \\' \
        && echo '  && exit 1 \\' \
        && echo ')' \
    ) > /install/install.sh \
    && chmod +x /install/install.sh \
    && cp /usr/local/lib/php/extensions/*/spx.so \
        /install/php-ext/ \
    && cp /usr/src/php/ext/php-spx/LICENSE \
        /install/usr/local/share/doc/php-spx/copyright \
    && cp -r /usr/src/php/ext/php-spx/assets /install/usr/local/share/misc/php-spx/

FROM scratch AS php-ext-spx
COPY --from=php-ext-spx-build /install /

FROM ${PHP_BASE_IMAGE} AS php-ext-spx-test
RUN --mount=type=cache,target=/var/cache/apt,sharing=private \
    --mount=type=cache,target=/var/lib/apt,sharing=private \
    --mount=type=bind,from=php-ext-spx,target=/usr/src/php-ext-spx \
    /usr/src/php-ext-spx/install.sh

RUN --mount=type=bind,from=php-ext-spx-build,source=/usr/src/php,target=/src/php,rw \
    mkdir -p /usr/src/php/ext \
    && cp -r /src/php/ext/php-spx /usr/src/php/ext/php-spx \
    && cd /usr/src/php/ext/php-spx \
    && sed -i 's#test: all#test:#' Makefile \
    && cp .libs/spx.lai modules/spx.la \
    && echo '#!/bin/bash' > run.sh \
    && echo 'set -e -o pipefail' >> run.sh \
    && echo 'php run-tests.php -j$(nproc) -q' >> run.sh \
    && chmod +x run.sh

WORKDIR /usr/src/php/ext/php-spx
CMD ["./run.sh"]

FROM php-ext-spx-test AS test

FROM php-ext-spx AS default
