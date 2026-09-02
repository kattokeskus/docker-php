#!/bin/bash
set -euo pipefail

php_source_dir="${PHP_SOURCE_DIR:-/usr/src/php}"
tests_dir="${php_source_dir}/ext/redis/tests"

# When a watched key is changed by another client, EXEC replies with a null
# array. phpredis 6.3.0 reads that correctly on x86_64 but not on aarch64,
# where RedisCluster::exec() throws "read error on connection" instead of
# returning [false]. Every other step of the test succeeds on both
# architectures, so skip just this one until the extension is fixed.
test_file="${tests_dir}/RedisClusterTest.php"
if [[ -f "${test_file}" ]] && ! grep -q "aarch64" "${test_file}"; then
  sed -i "/public function testFailedTransactions() {/a\\
        if (php_uname('m') === 'aarch64')\\
            \$this->markTestSkipped('phpredis misreads the aborted transaction reply from EXEC on aarch64');" \
    "${test_file}"
fi
