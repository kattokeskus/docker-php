ARG VIPS_VERSION

ARG PHP_EXT_BASE_IMAGE=scratch
ARG PHP_BASE_IMAGE=scratch

ARG EXTENSION_SCRATCH_IMAGE=scratch

FROM ${EXTENSION_SCRATCH_IMAGE} AS extension-scratch

FROM --platform=$BUILDPLATFORM ${PHP_EXT_BASE_IMAGE} AS vips-build
ARG TARGETARCH
ARG BUILDARCH

ARG BUILDDEPS=
ARG CONFIGURE=
ARG DEPS=

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    ([ ! -z "${BUILDDEPS}" ] || exit 0) \
    && apt-get update \
    && apt-get install -y -qq \
        $(for dep in $BUILDDEPS; do echo $dep:${TARGETARCH}; done)

ARG VIPS_VERSION
RUN cd /usr/src \
    && curl -sfL -o vips-${VIPS_VERSION}.tar.xz https://github.com/libvips/libvips/releases/download/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.xz \
    && tar -xJf vips-${VIPS_VERSION}.tar.xz \
    && rm vips-${VIPS_VERSION}.tar.xz \
    && mv vips-${VIPS_VERSION} vips

RUN cd /usr/src/vips \
    && ( \
        [ "${TARGETARCH}" = "${BUILDARCH}" ] \
        || ( \
            echo "[binaries]" >> cross-file.txt \
            && echo "c = '${TARGETARCH}-linux-gnu-gcc-12'" | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#' >> cross-file.txt \
            && echo "cpp = '${TARGETARCH}-linux-gnu-g++-12'" | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#' >> cross-file.txt \
            && echo "ar = '${TARGETARCH}-linux-gnu-ar'" | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#' >> cross-file.txt \
            && echo "strip = '${TARGETARCH}-linux-gnu-strip'" | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#' >> cross-file.txt \
            && echo "pkgconfig = '${TARGETARCH}-linux-gnu-pkg-config'" | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#' >> cross-file.txt \
            && echo "exe_wrapper = 'qemu-${TARGETARCH}-static'" | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#' >> cross-file.txt \
            && echo "[host_machine]" >> cross-file.txt \
            && echo "system = 'linux'" >> cross-file.txt \
            && echo "cpu_family = '${TARGETARCH}'" | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#' >> cross-file.txt \
            && echo "cpu = '${TARGETARCH}'" | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#' >> cross-file.txt \
            && echo "endian = 'little'" >> cross-file.txt \
        ) \
    ) \
    && ([ -f cross-file.txt ] || meson setup build) \
    && ([ ! -f cross-file.txt ] || meson setup --cross-file cross-file.txt build) \
    && cd build \
    && meson compile \
    && meson install \
    && ldconfig \
    && LD_LIBRARY_PATH=/usr/local/lib vips --version \
    && LD_LIBRARY_PATH=/usr/local/lib vips --vips-config \
    && echo "Verifying pdf support..." \
    && LD_LIBRARY_PATH=/usr/local/lib vips --vips-config | grep '^PDF' | grep -q ': true' \
    && echo "Verifying heic support..." \
    && LD_LIBRARY_PATH=/usr/local/lib vips --vips-config | grep '^HEIC' | grep -q ': true'

COPY --from=extension-scratch / /install/

RUN mkdir -p /install/usr/local/bin \
        /install/usr/local/include \
        /install/usr/local/share/doc/vips \
    && ( \
        echo '#!/bin/bash' \
        && echo 'set -e -o pipefail' \
        && echo \
        && echo 'cd "$(dirname "${BASH_SOURCE[0]}")"' \
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
        && echo '# Install vips' \
        && echo 'cp -rP usr/* /usr/' \
        && echo 'ldconfig' \
        && echo 'vips --version' \
    ) >> /install/install.sh \
    && chmod +x /install/install.sh \
    && cp -p /usr/local/bin/vips* /install/usr/local/bin/ \
    && cp -rp /usr/local/include/vips /install/usr/local/include/ \
    && ([ ! -f /usr/local/lib/libvips.so ] || ( \
        mkdir -p /install/usr/local/lib/pkgconfig \
        && cp -rp /usr/local/lib/libvips* /usr/local/lib/vips* /install/usr/local/lib/ \
        && cp -p /usr/local/lib/pkgconfig/vips* /install/usr/local/lib/pkgconfig/ \
    )) \
    && ([ -f /usr/local/lib/libvips.so ] || ( \
        [ -f /usr/local/lib/*/libvips.so ] \
        && mkdir -p /install/usr/local/lib/$(basename $(dirname /usr/local/lib/*/libvips.so))/pkgconfig \
        && cp -rp /usr/local/lib/*/libvips* /usr/local/lib/*/vips* /install/usr/local/lib/$(basename $(dirname /libvips-builder/usr/local/lib/*/libvips.so))/ \
        && cp -p /usr/local/lib/*/pkgconfig/vips* /install/usr/local/lib/$(basename $(dirname /libvips-builder/usr/local/lib/*/libvips.so))/pkgconfig/ \
    )) \
    && cp /usr/src/vips/LICENSE /install/usr/local/share/doc/vips/copyright

FROM ${EXTENSION_SCRATCH_IMAGE} AS vips
COPY --from=vips-build /install /

FROM docker.io/composer/composer:2.9.2 AS php-vips-source

ARG PHP_VIPS_VERSION

RUN mkdir -p /usr/src/php-vips \
    && cd /usr/src \
    && curl -sfL -o php-vips.tar.gz https://github.com/libvips/php-vips/archive/refs/tags/v${PHP_VIPS_VERSION}.tar.gz \
    && tar --strip-components=1 -xzf php-vips.tar.gz -C php-vips \
    && cd php-vips \
    && composer install --ignore-platform-reqs

FROM ${PHP_BASE_IMAGE} AS vips-test
RUN --mount=type=cache,target=/var/cache/apt,sharing=private \
    --mount=type=cache,target=/var/lib/apt,sharing=private \
    --mount=type=bind,from=vips,target=/usr/src/vips \
    apt-get update \
    && apt-get install -y -qq \
        bc \
    && /usr/src/vips/install.sh

COPY --from=php-vips-source /usr/src/php-vips /usr/src/php-vips

RUN --mount=type=bind,from=vips-build,source=/usr/src/vips,target=/src/vips,rw \
    mkdir -p /usr/src/ \
    && cp -r /src/vips /usr/src/vips \
    && cd /usr/src/vips \
    && (\
        echo '#!/bin/bash' \
        && echo 'set -euo pipefail' \
        && echo 'cd build/test' \
        && echo 'ret=0' \
        && echo 'for test in cli formats seq stall threading keep token connections descriptors timeout_webpsave timeout_gifsave; do' \
        && echo '  echo "Running test: $test"' \
        && echo '  if [[ -f "../../test/test_${test}.sh" ]]; then' \
        && echo '    "../../test/test_${test}.sh" || ret=$?' \
        && echo '  else' \
        && echo '    "./test_${test}" || ret=$?' \
        && echo '  fi' \
        && echo 'done' \
        && echo 'cd /usr/src/php-vips' \
        && echo 'echo "ffi.enable = On" > $PHP_INI_DIR/conf.d/php-vips.ini' \
        && echo 'echo "zend.max_allowed_stack_size = -1" >> $PHP_INI_DIR/conf.d/php-vips.ini' \
        && echo 'php vendor/bin/phpunit || ret=$?' \
        && echo 'exit $ret' \
    ) > run.sh \
    && chmod +x run.sh

WORKDIR /usr/src/vips
CMD ["./run.sh"]

FROM vips-test AS test

FROM vips AS default
