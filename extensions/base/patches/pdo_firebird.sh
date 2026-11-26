#!/bin/bash
set -euo pipefail

php_source_dir="${PHP_SOURCE_DIR:-/usr/src/php}"
tests_dir="${php_source_dir}/ext/pdo_firebird/tests"

# Backport php-src fec2055a: Firebird DSNs do not handle an IPv6 localhost
# address emitted by the payload server correctly.
sed -i 's#tcp://localhost:0#tcp://127.0.0.1:0#' \
  "${tests_dir}/payload_server.php"

# The shared PDO tests are found relative to the working directory, which
# run-tests.php workers on ZTS builds do not share with the main process, as
# chdir() only changes the virtual working directory there. Resolve them from
# run-tests.php like the other PDO drivers do.
sed -i "s#'TESTS' => 'ext/pdo/tests'#'TESTS' => __DIR__ . '/ext/pdo/tests'#" \
  "${tests_dir}/common.phpt"
