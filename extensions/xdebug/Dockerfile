ARG PHP_EXT_BASE_IMAGE=scratch
ARG PHP_BASE_IMAGE=scratch
ARG XDEBUG_VERSION

FROM --platform=$BUILDPLATFORM ${PHP_EXT_BASE_IMAGE} AS php-ext-xdebug-build
ARG TARGETARCH
ARG BUILDARCH

ARG XDEBUG_VERSION
RUN mkdir -p /usr/src/php/ext \
    && cd /usr/src/php/ext \
    && curl -sfL -o xdebug-${XDEBUG_VERSION}.tgz https://pecl.php.net/get/xdebug-${XDEBUG_VERSION}.tgz \
    && tar -xzf xdebug-${XDEBUG_VERSION}.tgz \
    && mv xdebug-${XDEBUG_VERSION} xdebug \
    && rm xdebug-${XDEBUG_VERSION}.tgz

RUN cd /usr/src/php/ext/xdebug \
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
        /install/usr/local/share/doc/php-xdebug \
    && ( \
        echo '#!/bin/bash' \
        && echo 'set -e -o pipefail' \
        && echo \
        && echo 'if php -m | grep -q "^xdebug$"; then' \
        && echo '  echo "xdebug already active"' \
        && echo '  exit 1' \
        && echo 'fi' \
        && echo \
        && echo 'cd "$(dirname "${BASH_SOURCE[0]}")"' \
        && echo \
        && echo '# Install xdebug extension' \
        && echo 'cp php-ext/* /usr/local/lib/php/extensions/*/' \
        && echo 'docker-php-ext-enable xdebug' \
        && echo 'php -m | grep -q "^xdebug$"' \
    ) > /install/install.sh \
    && chmod +x /install/install.sh \
    && cp /usr/local/lib/php/extensions/*/xdebug.so \
        /install/php-ext/ \
    && cp /usr/src/php/ext/xdebug/LICENSE \
        /install/usr/local/share/doc/php-xdebug/copyright

FROM scratch AS php-ext-xdebug
COPY --from=php-ext-xdebug-build /install /

FROM ${PHP_BASE_IMAGE} AS php-ext-xdebug-test
RUN --mount=type=cache,target=/var/cache/apt,sharing=private \
    --mount=type=cache,target=/var/lib/apt,sharing=private \
    --mount=type=bind,from=php-ext-xdebug,target=/usr/src/php-ext-xdebug \
    /usr/src/php-ext-xdebug/install.sh

ARG XDEBUG_VERSION
RUN --mount=type=bind,from=php-ext-xdebug-build,source=/usr/src/php,target=/src/php,rw \
    mkdir -p /usr/src/php/ext \
    && cp -r /src/php/ext/xdebug /usr/src/php/ext/xdebug \
    && cd /usr/src/php/ext/xdebug \
    && curl -sfL "https://github.com/xdebug/xdebug/archive/refs/tags/${XDEBUG_VERSION}.tar.gz" \
        | tar --strip-components=1 -xzf - xdebug-${XDEBUG_VERSION}/tests \
    && cp .libs/xdebug.lai modules/xdebug.la \
    && echo '#!/bin/bash' > run.sh \
    && echo 'set -e -o pipefail' >> run.sh \
    && echo 'ret=0' >> run.sh \
    && echo 'php -n \\' >> run.sh \
    && echo '    -d foo=yes \\' >> run.sh \
    && echo '    -d session.save_path=/tmp \\' >> run.sh \
    && echo '    run-xdebug-tests.php -j$(nproc) -q \\' >> run.sh \
    && echo '  || ret=$?' >> run.sh \
    && echo 'php -n \\' >> run.sh \
    && echo '    -d foo=yes \\' >> run.sh \
    && echo '    -d session.save_path=/tmp \\' >> run.sh \
    && echo '    -d zend_extensions=opcache.so \\' >> run.sh \
    && echo '    -d opcache.enable=1 \\' >> run.sh \
    && echo '    -d opcache.enable_cli=1 \\' >> run.sh \
    && echo '    run-xdebug-tests.php -j$(nproc) -q \\' >> run.sh \
    && echo '  && exit $ret' >> run.sh \
    && chmod +x run.sh

WORKDIR /usr/src/php/ext/xdebug
CMD ["./run.sh"]

FROM php-ext-xdebug-test AS test

FROM php-ext-xdebug AS default
