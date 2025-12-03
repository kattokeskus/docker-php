ARG PHP_EXT_BASE_IMAGE=scratch
ARG PHP_BASE_IMAGE=scratch
ARG IMAP_VERSION

FROM --platform=$BUILDPLATFORM ${PHP_EXT_BASE_IMAGE} AS php-ext-imap-build
ARG TARGETARCH
ARG BUILDARCH

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install -y -qq \
        libc-client2007e-dev:${TARGETARCH} \
        libkrb5-dev:${TARGETARCH}

ARG IMAP_VERSION
RUN mkdir -p /usr/src/php/ext/imap \
    && cd /usr/src/php/ext \
    && curl -sfL -o imap-${IMAP_VERSION}.tgz https://pecl.php.net/get/imap-${IMAP_VERSION}.tgz \
    && tar --strip-components=1 -xzf imap-${IMAP_VERSION}.tgz -C imap \
    && rm imap-${IMAP_VERSION}.tgz

RUN cd /usr/src/php/ext/imap \
    && phpize \
    && ./configure \
        --with-kerberos \
        --with-imap-ssl \
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
        /install/usr/local/share/doc/php-imap \
    && ( \
        echo '#!/bin/bash' \
        && echo 'set -e -o pipefail' \
        && echo \
        && echo 'if php -m | grep -q "^imap$"; then' \
        && echo '  echo "imap already active"' \
        && echo '  exit 1' \
        && echo 'fi' \
        && echo \
        && echo 'cd "$(dirname "${BASH_SOURCE[0]}")"' \
        && echo \
        && echo 'ARCH="$(dpkg --print-architecture)"' \
        && echo 'ARCH="${TARGETARCH:-$ARCH}"' \
        && echo "# Install dependencies" \
        && echo 'apt-get update' \
        && echo 'apt-get install -y -qq --no-install-recommends \\' \
        && echo '    libc-client2007e:${ARCH} \\' \
        && echo '    libkrb5-3:${ARCH}' \
        && echo \
        && echo '# Install imap extension' \
        && echo 'cp php-ext/* /usr/local/lib/php/extensions/*/' \
        && echo 'docker-php-ext-enable imap' \
        && echo 'php -m | grep -q "^imap$"' \
    ) > /install/install.sh \
    && chmod +x /install/install.sh \
    && cp /usr/local/lib/php/extensions/*/imap.so \
        /install/php-ext/ \
    && cp /usr/src/php/ext/imap/LICENSE \
        /install/usr/local/share/doc/php-imap/copyright

# Patch tests for rootless container
RUN [ -f /usr/src/php/ext/imap/tests/setup/dovecot.conf ] \
    && ( \
        echo \
        && echo 'service imap-login {' \
        && echo '  inet_listener imap {' \
        && echo '    port = 1143' \
        && echo '  }' \
        && echo '}' \
    ) >> /usr/src/php/ext/imap/tests/setup/dovecot.conf \
    && sed -i 's#127.0.0.1:143#127.0.0.1:1143#' /usr/src/php/ext/imap/tests/setup/imap_include.inc

FROM scratch AS php-ext-imap
COPY --from=php-ext-imap-build /install /

FROM ${PHP_BASE_IMAGE} AS php-ext-imap-test
RUN --mount=type=cache,target=/var/cache/apt,sharing=private \
    --mount=type=cache,target=/var/lib/apt,sharing=private \
    --mount=type=bind,from=php-ext-imap,target=/usr/src/php-ext-imap \
    /usr/src/php-ext-imap/install.sh

# Install test dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=private \
    --mount=type=cache,target=/var/lib/apt,sharing=private \
    apt-get update \
    && apt-get install -y -qq \
        libc-client2007e \
        libkrb5-dev \
        dovecot-core \
        dovecot-pop3d \
        dovecot-imapd \
        sendmail

RUN --mount=type=bind,from=php-ext-imap-build,source=/usr/src/php,target=/src/php,rw \
    mkdir -p /usr/src/php/ext \
    && cp -r /src/php/ext/imap /usr/src/php/ext/imap \
    && cd /usr/src/php/ext/imap \
    && sed -i 's#^sudo ##' tests/setup/setup.sh \
    && sed -i 's#test: all#test:#' Makefile \
    && rm -rf .libs modules \
    && mkdir modules \
    && ln -s "$(php-config --extension-dir)/imap.so" modules/imap.so \
    && echo '#!/bin/bash' > run.sh \
    && echo 'set -e -o pipefail' >> run.sh \
    && echo 'sh -c "cd /usr/src/php && sh ext/imap/tests/setup/setup.sh"' >> run.sh \
    && echo 'php run-tests.php -j$(nproc) -q' >> run.sh \
    && chmod +x run.sh

WORKDIR /usr/src/php/ext/imap
CMD ["./run.sh"]

FROM php-ext-imap-test AS test

FROM php-ext-imap AS default
