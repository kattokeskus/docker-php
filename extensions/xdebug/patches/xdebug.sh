#!/bin/bash
set -euo pipefail

php_source_dir="${PHP_SOURCE_DIR:-/usr/src/php}"
tests_dir="${php_source_dir}/ext/xdebug/tests"

# On ZTS builds Xdebug names the control socket after the thread ID
# (pthread_self()) instead of the process ID, but the control socket tests
# connect to xdebug-ctrl.<getmypid()>. Run them on NTS builds only, like the
# upstream tests that already require NTS.
for test_file in "${tests_dir}"/debugger/bug02424-*.phpt; do
  if [[ -f "${test_file}" ]]; then
    sed -i "s/^check_reqs('linux');$/check_reqs('linux; NTS');/" "${test_file}"
  fi
done
