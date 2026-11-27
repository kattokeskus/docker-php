#!/bin/bash
set -euo pipefail

php_source_dir="${PHP_SOURCE_DIR:-/usr/src/php}"
xdebug_dir="${php_source_dir}/ext/xdebug"
tests_dir="${xdebug_dir}/tests"

# On ZTS builds Xdebug names the control socket after the thread ID
# (pthread_self()) instead of the process ID, but the control socket tests
# connect to xdebug-ctrl.<getmypid()>. Run them on NTS builds only, like the
# upstream tests that already require NTS.
for test_file in "${tests_dir}"/debugger/bug02424-*.phpt; do
  if [[ -f "${test_file}" ]]; then
    sed -i "s/^check_reqs('linux');$/check_reqs('linux; NTS');/" "${test_file}"
  fi
done

# Xdebug 3.6 logs "Connecting to localhost: yes" after "Connecting to
# configured address/port". Its other control socket tests (bug02261-001 and
# the Windows variant) expect that line, but bug02261-002 was not updated. It
# only runs without a TSC clock, so here it fails on aarch64 only. Add the
# line only when the source logs it, so this is a no-op for Xdebug 3.5 and
# once the test is fixed.
test_file="${tests_dir}/debugger/bug02261-002.phpt"
if [[ -f "${test_file}" ]] \
  && grep -q 'Connecting to localhost' "${xdebug_dir}/src/debugger/com.c" \
  && ! grep -q 'Connecting to localhost' "${test_file}"; then
  sed -i '/^\[%d\] \[Step Debug\] INFO: Connecting to configured address\/port: %s$/a\
[%d] [Step Debug] INFO: Connecting to localhost: yes' "${test_file}"
  grep -q 'Connecting to localhost' "${test_file}"
fi
