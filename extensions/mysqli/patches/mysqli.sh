#!/bin/bash
set -euo pipefail

php_source_dir="${PHP_SOURCE_DIR:-/usr/src/php}"
tests_dir="${php_source_dir}/ext/mysqli/tests"

# The test image runs MariaDB, but a handful of upstream tests assert
# MySQL-specific server behaviour. Every hunk below is written so that it
# becomes a no-op once php-src ships the same change.

# Backport the PHP 8.5 fix: killing your own connection reports MariaDB's
# errno 1927 ("Connection was killed") instead of MySQL's 1317 ("Query
# execution was interrupted"). PHP 8.5 already accepts both codes.
for test in mysqli_thread_id.phpt mysqli_stmt_get_result.phpt; do
  test_file="${tests_dir}/${test}"

  if [[ ! -f "${test_file}" ]]; then
    continue
  fi

  sed -i 's/\$link->errno !== 1317)/$link->errno !== 1317 \&\& $link->errno !== 1927)/' \
    "${test_file}"
done

# MariaDB's VERSION() string ("10.11.18-MariaDB-0+deb12u1") is longer than the
# VARCHAR(25) stored procedure parameter these tests declare, so every CALL
# fails with errno 1406 (data too long for column).
for test in mysqli_stmt_execute_stored_proc.phpt mysqli_store_result_copy.phpt; do
  test_file="${tests_dir}/${test}"

  if [[ ! -f "${test_file}" ]]; then
    continue
  fi

  sed -i 's/\(ver_param\|ver_in\|ver_out\) VARCHAR(25)/\1 VARCHAR(64)/g' \
    "${test_file}"
done

# MariaDB has no native JSON type - JSON is an alias for LONGTEXT - so the
# field type comes back as MYSQLI_TYPE_BLOB (252) instead of MYSQLI_TYPE_JSON
# (245). Drop only that one datatype instead of skipping the whole test.
test_file="${tests_dir}/mysqli_fetch_field_types.phpt"
if [[ -f "${test_file}" ]] && ! grep -q 'no native JSON type' "${test_file}"; then
  sed -i '/foreach (\$datatypes as \$php_type => \$datatype) {/i\
    if (mysqli_get_server_version($link) >= 10_00_00) {\
        // MariaDB has no native JSON type, JSON is an alias for LONGTEXT\
        unset($datatypes[MYSQLI_TYPE_JSON]);\
    }\
' "${test_file}"
fi

# MariaDB rejects the over-long user name with errno 1698 ("Access denied for
# user") and no "(using password: %s)" suffix, so the reported warning cannot
# match. Skip like the sibling test mysqli_change_user_new.phpt already does.
test_file="${tests_dir}/mysqli_report_new.phpt"
if [[ -f "${test_file}" ]] && ! grep -q 'Not applicable for MariaDB' "${test_file}"; then
  sed -i '/if (mysqli_get_server_version(\$link) < 50600)/i\
if (mysqli_get_server_version($link) >= 10_00_00)\
    die("SKIP Not applicable for MariaDB");\
' "${test_file}"
fi

# MariaDB drops the connection during the TLS handshake instead of reporting a
# CA loading failure, so neither the warning nor the exception message match.
test_file="${tests_dir}/gh8978.phpt"
if [[ -f "${test_file}" ]] && ! grep -q 'Not applicable for MariaDB' "${test_file}"; then
  sed -i "/require_once 'skipifconnectfailure.inc';/a\\
\$link = my_mysqli_connect(\$host, \$user, \$passwd, \$db, \$port, \$socket);\\
if (mysqli_get_server_version(\$link) >= 10_00_00)\\
    die(\"SKIP Not applicable for MariaDB\");\\
" "${test_file}"
fi
