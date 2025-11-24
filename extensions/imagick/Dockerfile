ARG PHP_EXT_BASE_IMAGE=scratch
ARG PHP_BASE_IMAGE=scratch
ARG IMAGEMAGICK_VERSION
ARG IMAGICK_VERSION

FROM --platform=$BUILDPLATFORM ${PHP_EXT_BASE_IMAGE} AS imagemagick-build
ARG TARGETARCH
ARG BUILDARCH
ARG BUILDDEPS=
ARG DEPS=

# Install dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install -y -qq --no-install-recommends \
        $(for dep in $BUILDDEPS; do echo $dep:${TARGETARCH}; done)

ARG IMAGEMAGICK_VERSION
# Download imagemagick source
RUN mkdir -p /usr/src \
    && cd /usr/src \
    && curl -sfL -o ImageMagick-${IMAGEMAGICK_VERSION}.tar.gz https://github.com/ImageMagick/ImageMagick/archive/refs/tags/${IMAGEMAGICK_VERSION}.tar.gz \
    && tar xzf ImageMagick-${IMAGEMAGICK_VERSION}.tar.gz \
    && rm ImageMagick-${IMAGEMAGICK_VERSION}.tar.gz \
    && mv ImageMagick-${IMAGEMAGICK_VERSION} ImageMagick

# Configure imagemagick
RUN cd /usr/src/ImageMagick \
    && ./configure \
        --enable-static \
        --enable-shared \
        --with-modules \
        --with-fftw \
        --with-gslib \
        --with-heic \
        --with-rsvg \
        --with-webp \
        --with-wmf \
        --with-perl \
        --with-dejavu-font-dir=/usr/share/fonts/truetype/dejavu \
        --with-urw-base35-font-dir=/usr/share/fonts/type1/urw-base35 \
        --build `echo ${BUILDARCH} | sed  -e 's#arm64#aarch64#' -e 's#amd64#x86_64#'`-none-linux \
        --host `echo ${TARGETARCH} | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#'`-none-linux \
        `[ "${TARGETARCH}" != "${BUILDARCH}" ] \
            && echo CC=${TARGETARCH}-linux-gnu-gcc-12 | sed  -e 's#arm64#aarch64#' -e 's#amd64#x86_64#' \
            && echo CXX=${TARGETARCH}-linux-gnu-g++-12 | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#' \
            && echo PKG_CONFIG=/usr/bin/${TARGETARCH}-linux-gnu-pkg-config | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#' \
        `
# Install imagemagick
RUN cd /usr/src/ImageMagick \
    && make -j$(nproc) \
    && make install \
    && ldconfig /usr/local/lib \
    && ([ "${TARGETARCH}" != "${BUILDARCH}" ] || magick --version)

# Create install directory
RUN \
    mkdir -p /install \
    && ( \
        echo '#!/bin/bash' \
        && echo 'set -e -o pipefail' \
        && echo \
        && echo 'cd "$(dirname "${BASH_SOURCE[0]}")"' \
        && echo \
        && echo '# Detect if cross compile environment' \
        && echo 'TARGETARCH=${TARGETARCH:-$(dpkg --print-architecture)}' \
        && echo 'BUILDARCH=${BUILDARCH:-$(dpkg --print-architecture)}' \
        && echo \
        && echo '# Install dependencies' \
        && echo "DEPS=\"${DEPS}\"" \
        && echo 'ARCH="$(dpkg --print-architecture)"' \
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
        && echo '    $DEPS' \
        && echo 'fi' \
        && echo \
        && echo '# Install imagemagick' \
        && echo 'cp -rP usr/* /usr' \
        && echo 'ldconfig /usr/local/lib' \
        && echo '([ "${TARGETARCH}" != "${BUILDARCH}" ] || magick --version)' \
    ) > /install/install.sh \
    && chmod +x /install/install.sh \
    && mkdir -p /install/usr/local/bin \
        /install/usr/local/etc \
        /install/usr/local/include \
        /install/usr/local/lib/pkgconfig \
        /install/usr/local/share \
    && cp -P /usr/local/bin/Magic* \
        /usr/local/bin/animate \
        /usr/local/bin/compare \
        /usr/local/bin/composite \
        /usr/local/bin/conjure \
        /usr/local/bin/convert \
        /usr/local/bin/display \
        /usr/local/bin/identify \
        /usr/local/bin/import \
        /usr/local/bin/magick \
        /usr/local/bin/magick-script \
        /usr/local/bin/mogrify \
        /usr/local/bin/montage \
        /usr/local/bin/stream \
        /install/usr/local/bin/ \
    && cp -rP /usr/local/etc/ImageMagick-* \
        /install/usr/local/etc/ \
    && cp -rP /usr/local/include/ImageMagick-* \
        /install/usr/local/include/ \
    && cp -rP /usr/local/lib/ImageMagick-* \
        /usr/local/lib/libMagick* \
        /install/usr/local/lib/ \
    && cp -rP /usr/local/lib/pkgconfig/ImageMagick* \
        /usr/local/lib/pkgconfig/Magick* \
        /install/usr/local/lib/pkgconfig/ \
    && cp -rP /usr/local/share/ImageMagick-* \
        /install/usr/local/share/

RUN cd /usr/src/ImageMagick \
    && make tests/validate

FROM scratch AS imagemagick
COPY --from=imagemagick-build /install /

FROM ${PHP_BASE_IMAGE} AS imagemagick-test
RUN --mount=type=cache,target=/var/cache/apt,sharing=private \
    --mount=type=cache,target=/var/lib/apt,sharing=private \
    --mount=type=bind,from=imagemagick,target=/usr/src/imagemagick \
    /usr/src/imagemagick/install.sh

FROM --platform=$BUILDPLATFORM ${PHP_EXT_BASE_IMAGE} AS php-ext-imagick-build
ARG TARGETARCH
ARG BUILDARCH

COPY --from=imagemagick / /install
RUN TARGETARCH=${TARGETARCH} \
    BUILDARCH=${BUILDARCH} \
    /install/install.sh

ARG IMAGICK_VERSION
RUN mkdir -p /usr/src/php/ext \
    && cd /usr/src/php/ext \
    && curl -sfL -o imagick-${IMAGICK_VERSION}.tgz https://pecl.php.net/get/imagick-${IMAGICK_VERSION}.tgz \
    && tar xzf imagick-${IMAGICK_VERSION}.tgz \
    && rm imagick-${IMAGICK_VERSION}.tgz \
    && mv imagick-${IMAGICK_VERSION} imagick

RUN cd /usr/src/php/ext/imagick \
    && phpize \
    && ./configure \
    --build `echo ${BUILDARCH} | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#'`-none-linux \
    --host `echo ${TARGETARCH} | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#'`-none-linux \
    `[ "${TARGETARCH}" != "${BUILDARCH}" ] \
        && echo CC=${TARGETARCH}-linux-gnu-gcc-12 | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#' \
        && echo CXX=${TARGETARCH}-linux-gnu-g++-12 | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#' \
        && echo PKG_CONFIG=/usr/bin/${TARGETARCH}-linux-gnu-pkg-config | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#' \
    ` \
    && make -j$(nproc) \
    && make install

RUN mkdir -p /install/php-ext \
        /install/usr/local/include/php/ext \
        /install/usr/local/share/doc/php-imagick \
    && cp /usr/local/lib/php/extensions/*/imagick.so \
        /install/php-ext/ \
    && cp -rP /usr/local/include/php/ext/imagick \
        /install/usr/local/include/php/ext/ \
    && ( \
        echo \
        && echo 'if php -m | grep -q "^imagick$"; then' \
        && echo '  echo "imagick already active"' \
        && echo '  exit 1' \
        && echo 'fi' \
        && echo \
        && echo '# Install imagick extension' \
        && echo 'cp php-ext/* /usr/local/lib/php/extensions/*/' \
        && echo 'docker-php-ext-enable imagick' \
        && echo 'php -m | grep -q "^imagick$"' \
    ) >> /install/install.sh \
    && cp /usr/src/php/ext/imagick/LICENSE \
        /install/usr/local/share/doc/php-imagick/copyright

FROM scratch AS php-ext-imagick
COPY --from=php-ext-imagick-build /install /

FROM imagemagick-test AS php-ext-imagick-test
RUN --mount=type=cache,target=/var/cache/apt,sharing=private \
    --mount=type=cache,target=/var/lib/apt,sharing=private \
    --mount=type=bind,from=php-ext-imagick,target=/usr/src/php-ext-imagick \
    /usr/src/php-ext-imagick/install.sh

RUN --mount=type=bind,from=php-ext-imagick-build,source=/usr/src/php,target=/src/php,rw \
--mount=type=bind,from=imagemagick-build,source=/usr/src/ImageMagick,target=/src/ImageMagick,rw \
    mkdir -p /usr/src/ImageMagick \
    && cp -r /src/ImageMagick/tests /usr/src/ImageMagick/tests \
    && mkdir -p /usr/src/php/ext \
    && cp -r /src/php/ext/imagick /usr/src/php/ext/imagick \
    && cd /usr/src/php/ext/imagick \
    && sed -i 's#test: all#test:#' Makefile \
    && rm -rf .libs modules \
    && mkdir modules \
    && ln -s "$(php-config --extension-dir)/imagick.so" modules/imagick.so \
    && echo '#!/bin/bash' > run.sh \
    && echo 'set -e -o pipefail' >> run.sh \
    && echo '/usr/src/ImageMagick/tests/validate' >> run.sh \
    && echo 'php run-tests.php -j$(nproc) -q' >> run.sh \
    && chmod +x run.sh

WORKDIR /usr/src/php/ext/imagick
CMD ["./run.sh"]

FROM php-ext-imagick-test AS test

FROM php-ext-imagick AS default
