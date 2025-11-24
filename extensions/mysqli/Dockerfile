ARG PHP_EXT_BASE_IMAGE=scratch
ARG PHP_BASE_IMAGE=scratch

FROM --platform=$BUILDPLATFORM ${PHP_EXT_BASE_IMAGE} AS php-ext-mysqli-build
ARG TARGETARCH
ARG BUILDARCH

RUN cd /usr/src/php/ext/mysqli \
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
        /install/usr/local/include/php/ext \
        /install/usr/local/share/doc/php-mysqli \
    && ( \
        echo '#!/bin/bash' \
        && echo 'set -e -o pipefail' \
        && echo \
        && echo 'if php -m | grep -q "^mysqli$"; then' \
        && echo '  echo "mysqli already active"' \
        && echo '  exit 1' \
        && echo 'fi' \
        && echo \
        && echo 'cd "$(dirname "${BASH_SOURCE[0]}")"' \
        && echo \
        && echo '# Install mysqli extension' \
        && echo 'cp php-ext/* /usr/local/lib/php/extensions/*/' \
        && echo 'cp -rP usr/* /usr/' \
        && echo 'docker-php-ext-enable mysqli' \
        && echo 'php -m | grep -q "^mysqli$"' \
    ) > /install/install.sh \
    && chmod +x /install/install.sh \
    && cp /usr/local/lib/php/extensions/*/mysqli.so \
        /install/php-ext/ \
    && cp -rP /usr/local/include/php/ext/mysqli \
        /install/usr/local/include/php/ext/ \
    && cp /usr/src/php/LICENSE \
        /install/usr/local/share/doc/php-mysqli/copyright

FROM scratch AS php-ext-mysqli
COPY --from=php-ext-mysqli-build /install /

FROM ${PHP_BASE_IMAGE} AS php-ext-mysqli-test-action
RUN --mount=type=cache,target=/var/cache/apt,sharing=private \
    --mount=type=cache,target=/var/lib/apt,sharing=private \
    --mount=type=bind,from=php-ext-mysqli,target=/usr/src/php-ext-mysqli \
    /usr/src/php-ext-mysqli/install.sh

ENV MYSQL_TEST_HOST=127.0.0.1 \
    MYSQL_TEST_USER=root \
    MYSQL_TEST_DB=test \
    MYSQL_TEST_PASSWD=test

FROM php-ext-mysqli-test-action AS php-ext-mysqli-test
RUN --mount=type=cache,target=/var/cache/apt,sharing=private \
    --mount=type=cache,target=/var/lib/apt,sharing=private \
    apt-get update \
    && apt-get install -y -qq \
        mariadb-server \
        mariadb-client

RUN --mount=type=bind,from=php-ext-mysqli-build,source=/usr/src/php,target=/src/php,rw \
    mkdir -p /usr/src/php/ext \
    && cp -r /src/php/ext/mysqli /usr/src/php/ext/mysqli \
    && cd /usr/src/php/ext/mysqli \
    && sed -i 's#test: all#test:#' Makefile \
    && rm -rf .libs modules \
    && mkdir modules \
    && ln -s "$(php-config --extension-dir)/mysqli.so" modules/mysqli.so \
    && echo '#!/bin/bash' > run.sh \
    && echo 'set -e -o pipefail' >> run.sh \
    && echo 'service mariadb start' >> run.sh \
    && echo 'mariadb -uroot -e "CREATE DATABASE ${MYSQL_TEST_DB};SET PASSWORD FOR '"'"'${MYSQL_TEST_USER}'"'"'@'"'"'localhost'"'"'=PASSWORD('"'"'${MYSQL_TEST_PASSWD}'"'"');"' >> run.sh \
    && echo 'mariadb -h127.0.0.1 -u${MYSQL_TEST_USER} -p${MYSQL_TEST_PASSWD} ${MYSQL_TEST_DB} -e "SELECT '"'"'DB OK'"'"';"' >> run.sh \
    && echo 'php run-tests.php -j$(nproc) -q' >> run.sh \
    && chmod +x run.sh

WORKDIR /usr/src/php/ext/mysqli
CMD ["./run.sh"]

FROM php-ext-mysqli-test-action AS test-action

FROM php-ext-mysqli-test AS test

FROM php-ext-mysqli AS default
