ARG PHP_EXT_BASE_IMAGE=scratch
ARG PHP_BASE_IMAGE=scratch
ARG REDIS_VERSION

FROM --platform=$BUILDPLATFORM ${PHP_EXT_BASE_IMAGE} AS php-ext-redis-build
ARG TARGETARCH
ARG BUILDARCH

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install -y -qq \
        liblzf-dev:${TARGETARCH} \
        libzstd-dev:${TARGETARCH} \
        liblz4-dev:${TARGETARCH}

ARG REDIS_VERSION
RUN mkdir -p /usr/src/php/ext/redis \
    && cd /usr/src/php/ext \
    && curl -sfL -o redis-${REDIS_VERSION}.tgz https://pecl.php.net/get/redis-${REDIS_VERSION}.tgz \
    && tar --strip-components=1 -xzf redis-${REDIS_VERSION}.tgz -C redis \
    && rm redis-${REDIS_VERSION}.tgz

RUN cd /usr/src/php/ext/redis \
    && phpize \
    && ./configure \
        --enable-redis-lzf \
        --enable-redis-zstd \
        --enable-redis-lz4 \
        --with-liblz4=/usr/lib/`echo ${TARGETARCH} | sed -e 's#arm64#aarch64#' -e 's#amd64#x86_64#'`-linux-gnu/pkgconfig/liblz4.pc \
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
        /install/usr/local/share/doc/php-redis \
    && ( \
        echo '#!/bin/bash' \
        && echo 'set -e -o pipefail' \
        && echo \
        && echo 'if php -m | grep -q "^redis$"; then' \
        && echo '  echo "redis already active"' \
        && echo '  exit 1' \
        && echo 'fi' \
        && echo \
        && echo 'cd "$(dirname "${BASH_SOURCE[0]}")"' \
        && echo \
        && echo '# Install dependencies' \
        && echo 'apt-get update' \
        && echo 'apt-get install -y -qq --no-install-recommends \\' \
        && echo '    liblzf1 \\' \
        && echo '    libzstd1 \\' \
        && echo '    liblz4-1 \\' \
        && echo \
        && echo '# Install redis extension' \
        && echo 'cp php-ext/* /usr/local/lib/php/extensions/*/' \
        && echo 'docker-php-ext-enable redis' \
        && echo 'php -m | grep -q "^redis$"' \
    ) > /install/install.sh \
    && chmod +x /install/install.sh \
    && cp /usr/local/lib/php/extensions/*/redis.so \
        /install/php-ext/ \
    && cp /usr/src/php/ext/redis/LICENSE \
        /install/usr/local/share/doc/php-redis/copyright

FROM scratch AS php-ext-redis
COPY --from=php-ext-redis-build /install /

FROM ${PHP_BASE_IMAGE} AS php-ext-redis-test
RUN --mount=type=cache,target=/var/cache/apt,sharing=private \
    --mount=type=cache,target=/var/lib/apt,sharing=private \
    --mount=type=bind,from=php-ext-redis,target=/usr/src/php-ext-redis \
    /usr/src/php-ext-redis/install.sh

RUN --mount=type=cache,target=/var/cache/apt,sharing=private \
    --mount=type=cache,target=/var/lib/apt,sharing=private \
    apt-get update \
    && apt-get install -y -qq \
        redis

RUN pecl install igbinary

# TODO: Add sentinel
RUN --mount=type=bind,from=php-ext-redis-build,source=/usr/src/php,target=/src/php,rw \
    mkdir -p /usr/src/php/ext \
    && cp -r /src/php/ext/redis /usr/src/php/ext/redis \
    && cd /usr/src/php/ext/redis \
    && echo "user default on >phpredis ~* +@all" > tests/users.acl \
    && echo "user phpredis on >phpredis ~* +@all" >> tests/users.acl \
    && echo '#!/bin/bash' > run.sh \
    && echo 'set -e -o pipefail' >> run.sh \
    && echo >> run.sh \
    && echo '# Start redis-server' >> run.sh \
    && echo "for PORT in 6379 6380 6381 6382 32767 32768 32769; do" >> run.sh \
    && echo '    redis-server --port $PORT \\' >> run.sh \
    && echo '        --daemonize yes \\' >> run.sh \
    && echo '        --aclfile tests/users.acl \\' >> run.sh \
    && echo '        --acl-pubsub-default allchannels' >> run.sh \
    && echo 'done' >> run.sh \
    && echo >> run.sh \
    && echo 'redis-server --port 0 \\' >> run.sh \
    && echo '        --unixsocket /tmp/redis.sock \\' >> run.sh \
    && echo '        --daemonize yes \\' >> run.sh \
    && echo '        --aclfile tests/users.acl \\' >> run.sh \
    && echo '        --acl-pubsub-default allchannels' >> run.sh \
    && echo >> run.sh \
    && echo 'mkdir -p tests/nodes' >> run.sh \
    && echo 'echo -n > tests/nodes/nodemap' >> run.sh \
    && echo 'for PORT in 7000 7001 7002 7003 7004 7005; do' >> run.sh \
    && echo '    redis-server --port $PORT \\' >> run.sh \
    && echo '        --cluster-enabled yes \\' >> run.sh \
    && echo '        --cluster-config-file "$PORT".conf \\' >> run.sh \
    && echo '        --daemonize yes \\' >> run.sh \
    && echo '        --aclfile tests/users.acl \\' >> run.sh \
    && echo '        --acl-pubsub-default allchannels' >> run.sh \
    && echo '    echo "127.0.0.1:$PORT" >> tests/nodes/nodemap' >> run.sh \
    && echo 'done' >> run.sh \
    && echo >> run.sh \
    && echo 'i=0' >> run.sh \
    && echo 'for PORT in 6379 6380 6381 6382 32767 32768 32769 7000 7001 7002 7003 7004 7005; do' >> run.sh \
    && echo '    until echo PING | redis-cli -p "$PORT" 2>&1 | grep -qE "PONG|NOAUTH"; do' >> run.sh \
    && echo '        echo "Still waiting for redis-server to start on port $PORT"' >> run.sh \
    && echo '        i=$((i+1))' >> run.sh \
    && echo '        if [ $i -ge 60 ]; then' >> run.sh \
    && echo '            echo "redis-server failed to start on port $PORT"' >> run.sh \
    && echo '            exit 1' >> run.sh \
    && echo '        fi' >> run.sh \
    && echo '        sleep 1;' >> run.sh \
    && echo '    done' >> run.sh \
    && echo 'done' >> run.sh \
    && echo >> run.sh \
    && echo 'i=0' >> run.sh \
    && echo 'until echo PING | redis-cli -s /tmp/redis.sock 2>&1 | grep -qE "PONG|NOAUTH"; do' >> run.sh \
    && echo '    echo "Still waiting for redis-server to start on socket /tmp/redis.sock"' >> run.sh \
    && echo '    i=$((i+1))' >> run.sh \
    && echo '    if [ $i -ge 60 ]; then' >> run.sh \
    && echo '        echo "redis-server failed to start on socket /tmp/redis.sock"' >> run.sh \
    && echo '        exit 1' >> run.sh \
    && echo '    fi' >> run.sh \
    && echo '    sleep 1;' >> run.sh \
    && echo 'done' >> run.sh \
    && echo >> run.sh \
    && echo 'yes yes | redis-cli --cluster create 127.0.0.1:7000 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005 \\' >> run.sh \
    && echo '    --cluster-replicas 1 \\' >> run.sh \
    && echo '    --user phpredis \\' >> run.sh \
    && echo '    -a phpredis || true' >> run.sh \
    && echo >> run.sh \
    && echo 'make test' >> run.sh \
    && echo 'ret=0' >> run.sh \
    && echo 'TEST_PHP_ARGS="-e" php tests/TestRedis.php --class Redis --user phpredis --auth phpredis' >> run.sh \
    && echo '[ $? -ne 0 ] && ret=1' >> run.sh \
    && echo 'TEST_PHP_ARGS="-e" php tests/TestRedis.php --class RedisArray --user phpredis --auth phpredis' >> run.sh \
    && echo '[ $? -ne 0 ] && ret=1' >> run.sh \
    && echo 'TEST_PHP_ARGS="-e" php tests/TestRedis.php --class RedisCluster --user phpredis --auth phpredis' >> run.sh \
    && echo '[ $? -ne 0 ] && ret=1' >> run.sh \
    && echo 'exit $ret' >> run.sh \
    && chmod +x run.sh

WORKDIR /usr/src/php/ext/redis
CMD ["./run.sh"]

FROM php-ext-redis-test AS test

FROM php-ext-redis AS default
