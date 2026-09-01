ARG PHP_EXT_BASE_IMAGE=scratch
ARG PHP_BASE_IMAGE=scratch

FROM --platform=$BUILDPLATFORM ${PHP_EXT_BASE_IMAGE} AS php-ext-mysqli-build
ARG TARGETARCH
ARG BUILDARCH
ARG GCC_VERSION=14

RUN cd /usr/src/php/ext/mysqli \
    && phpize \
    && ./configure \
        --build `echo ${BUILDARCH} | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#'`-none-linux \
        --host `echo ${TARGETARCH} | sed  -e 's#arm64#aarch64#' -e 's#amd64#x86_64#'`-none-linux \
        `[ "${TARGETARCH}" != "${BUILDARCH}" ] \
            && echo CC=${TARGETARCH}-linux-gnu-gcc-${GCC_VERSION} | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#' \
            && echo CXX=${TARGETARCH}-linux-gnu-g++-${GCC_VERSION} | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#' \
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

# MariaDB 11.x defaults to the UCA-1400 collations, which mysqlnd's built-in
# charset table does not know, so field metadata comes back with the wrong
# collation id and name. Pin the legacy defaults to keep the upstream tests
# comparable between bookworm (MariaDB 10.11) and trixie (MariaDB 11.8).
# character_set_collations only exists from 11.5 onwards, hence loose_.
RUN printf '%s\n' \
        '[mariadbd]' \
        'loose_character_set_collations = utf8mb3=utf8mb3_general_ci,utf8mb4=utf8mb4_general_ci' \
        'collation_server = utf8mb4_general_ci' \
        > /etc/mysql/mariadb.conf.d/99-php-tests.cnf

RUN --mount=type=bind,from=php-ext-mysqli-build,source=/usr/src/php,target=/src/php,rw \
    --mount=type=bind,source=patches,target=/usr/src/php-test-patches \
    mkdir -p /usr/src/php/ext \
    && cp -r /src/php/ext/mysqli /usr/src/php/ext/mysqli \
    && cd /usr/src/php/ext/mysqli \
    && if [ -f "/usr/src/php-test-patches/mysqli.sh" ]; then \
        bash "/usr/src/php-test-patches/mysqli.sh"; \
    fi \
    && sed -i 's#test: all#test:#' Makefile \
    && rm -rf .libs modules \
    && mkdir modules \
    && ln -s "$(php-config --extension-dir)/mysqli.so" modules/mysqli.so \
    && echo '#!/bin/bash' > run.sh \
    && echo 'set -e -o pipefail' >> run.sh \
    && echo 'service mariadb start' >> run.sh \
    && echo 'mariadb -uroot -e "CREATE DATABASE ${MYSQL_TEST_DB};SET PASSWORD FOR '"'"'${MYSQL_TEST_USER}'"'"'@'"'"'localhost'"'"'=PASSWORD('"'"'${MYSQL_TEST_PASSWD}'"'"');"' >> run.sh \
    && echo 'mariadb -h127.0.0.1 -u${MYSQL_TEST_USER} -p${MYSQL_TEST_PASSWD} ${MYSQL_TEST_DB} -e "SELECT '"'"'DB OK'"'"';"' >> run.sh \
    && echo 'php run-tests.php -j$(nproc) -q --show-diff' >> run.sh \
    && chmod +x run.sh

WORKDIR /usr/src/php/ext/mysqli
CMD ["./run.sh"]

FROM php-ext-mysqli-test-action AS test-action

FROM php-ext-mysqli-test AS test

FROM php-ext-mysqli AS default
