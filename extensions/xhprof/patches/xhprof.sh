#!/bin/bash
set -euo pipefail

php_source_dir="${PHP_SOURCE_DIR:-/usr/src/php}"
tests_dir="${php_source_dir}/ext/xhprof/extension/tests"

# PHP 8.5 deprecated curl_close(), which has had no effect since PHP 8.0.
# Calling it emits a deprecation notice and, because the diagnostic
# instantiates the #[\Deprecated] attribute, also adds Deprecated::__construct
# to the recorded call graph, so neither the output nor the profile match.
# Suppressing the notice does not help, the attribute is still constructed.
# The test is about the additional info xhprof records for curl_exec, so drop
# the no-op call and the call graph entry it produced.
test_file="${tests_dir}/xhprof_012.phpt"
if [[ -f "${test_file}" ]]; then
  sed -i -e '/^curl_close(\$ch);$/d' -e '/^main()==>curl_close /d' "${test_file}"
fi
