#!/bin/bash
set -euo pipefail

php_source_dir="${PHP_SOURCE_DIR:-/usr/src/php}"
tests_dir="${php_source_dir}/ext/pdo_odbc/tests"

# The shared PDO tests are found relative to the working directory, which
# run-tests.php workers on ZTS builds do not share with the main process, as
# chdir() only changes the virtual working directory there. Resolve them from
# run-tests.php like the other PDO drivers do.
sed -i "s#'TESTS' => 'ext/pdo/tests'#'TESTS' => __DIR__ . '/ext/pdo/tests'#" \
  "${tests_dir}/common.phpt"
