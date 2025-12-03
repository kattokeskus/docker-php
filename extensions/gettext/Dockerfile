ARG PHP_EXT_BASE_IMAGE=scratch
ARG PHP_BASE_IMAGE=scratch

FROM --platform=$BUILDPLATFORM ${PHP_EXT_BASE_IMAGE} AS php-ext-gettext-build
ARG TARGETARCH
ARG BUILDARCH

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install -y -qq \
        gettext:${TARGETARCH} \
        libgettextpo-dev:${TARGETARCH}

RUN cd /usr/src/php/ext/gettext \
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
        /install/usr/local/share/doc/php-gettext \
    && ( \
        echo '#!/bin/bash' \
        && echo 'set -e -o pipefail' \
        && echo \
        && echo 'if php -m | grep -q "^gettext$"; then' \
        && echo '  echo "gettext already active"' \
        && echo '  exit 1' \
        && echo 'fi' \
        && echo \
        && echo 'cd "$(dirname "${BASH_SOURCE[0]}")"' \
        && echo \
        && echo 'ARCH="$(dpkg --print-architecture)"' \
        && echo 'ARCH="${TARGETARCH:-$ARCH}"' \
        && echo '# Install dependencies' \
        && echo 'apt-get update' \
        && echo 'apt-get install -y -qq --no-install-recommends \\' \
        && echo '    gettext:${ARCH} \\' \
        && echo '    locales' \
        && echo \
        && echo '# Reconfigure locales' \
        && echo 'if [ -z "$ENABLED_LOCALES" ]; then' \
        && echo '  ENABLED_LOCALES="en_US"' \
        && echo 'fi' \
        && echo 'for locale in $ENABLED_LOCALES; do' \
        && echo '  grep "^$locale" /usr/share/i18n/SUPPORTED >> /etc/locale.gen' \
        && echo '  grep -q "^$locale" /etc/locale.gen || echo "Locale $locale not supported" >&2' \
        && echo 'done' \
        && echo 'dpkg-reconfigure --frontend=noninteractive locales' \
        && echo \
        && echo '# Install gettext extension' \
        && echo 'cp php-ext/* /usr/local/lib/php/extensions/*/' \
        && echo 'docker-php-ext-enable gettext' \
        && echo 'php -m | grep -q "^gettext$"' \
    ) > /install/install.sh \
    && chmod +x /install/install.sh \
    && cp /usr/local/lib/php/extensions/*/gettext.so \
        /install/php-ext/ \
    && cp /usr/src/php/LICENSE \
        /install/usr/local/share/doc/php-gettext/copyright

FROM scratch AS php-ext-gettext
COPY --from=php-ext-gettext-build /install /

FROM ${PHP_BASE_IMAGE} AS php-ext-gettext-test
RUN --mount=type=cache,target=/var/cache/apt,sharing=private \
    --mount=type=cache,target=/var/lib/apt,sharing=private \
    --mount=type=bind,from=php-ext-gettext,target=/usr/src/php-ext-gettext \
    /usr/src/php-ext-gettext/install.sh

RUN --mount=type=bind,from=php-ext-gettext-build,source=/usr/src/php,target=/src/php,rw \
    mkdir -p /usr/src/php/ext \
    && cp -r /src/php/ext/gettext /usr/src/php/ext/gettext \
    && cd /usr/src/php/ext/gettext \
    && sed -i 's#test: all#test:#' Makefile \
    && rm -rf .libs modules \
    && mkdir modules \
    && ln -s "$(php-config --extension-dir)/gettext.so" modules/gettext.so \
    && grep 'fi_FI' /usr/share/i18n/SUPPORTED >> /etc/locale.gen \
    && grep 'de_DE' /usr/share/i18n/SUPPORTED >> /etc/locale.gen \
    && grep 'fr_FR' /usr/share/i18n/SUPPORTED >> /etc/locale.gen \
    && grep 'en_US' /usr/share/i18n/SUPPORTED >> /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && echo '#!/bin/bash' > run.sh \
    && echo 'set -e -o pipefail' >> run.sh \
    && echo 'php run-tests.php -j$(nproc) -q' >> run.sh \
    && chmod +x run.sh

WORKDIR /usr/src/php/ext/gettext
CMD ["./run.sh"]

FROM php-ext-gettext-test AS test

FROM php-ext-gettext AS default
