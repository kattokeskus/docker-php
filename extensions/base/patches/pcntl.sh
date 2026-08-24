#!/bin/bash
set -euo pipefail

php_source_dir="${PHP_SOURCE_DIR:-/usr/src/php}"
tests_dir="${php_source_dir}/ext/pcntl/tests"

# Backport the privilege check from php-src fb257ee8. The setns tests require
# capabilities that are intentionally unavailable in CI.
for test in pcntl_setns_basic.phpt pcntl_setns_newpid.phpt; do
  test_file="${tests_dir}/${test}"

  if [[ ! -f "${test_file}" ]]; then
    continue
  fi

  if grep -q 'Insufficient privileges to use pcntl_setns' "${test_file}"; then
    continue
  fi

  sed -i "/^if (posix_getuid() !== 0) die('skip Test needs root user');$/d" "${test_file}"
  sed -i "/if (getenv('SKIP_ASAN'))/a\\
\\
\$pid = pcntl_fork();\\
if (\$pid == -1) die(\"skip pcntl_fork failed\");\\
if (\$pid != 0) {\\
    if (@pcntl_setns(\$pid, CLONE_NEWPID) === false && pcntl_get_last_error() == PCNTL_EPERM) {\\
        die(\"skip Insufficient privileges to use pcntl_setns()\");\\
    }\\
}" "${test_file}"
done
