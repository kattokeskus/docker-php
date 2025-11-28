# Prebuilt PHP Extensions

This project provides prebuilt PHP extension images that can be installed into PHP base images.

## Using Prebuilt Extensions

To install a prebuilt extension into your PHP image, mount the extension image and run its install script:

```
ARG PHP_VERSION=8.3.27
ARG PHP_VARIANT=bookworm
ARG EXTENSION=calendar
ARG EXTENSION_VERSION=${PHP_VERSION}
FROM php:${PHP_VERSION}-${PHP_VARIANT}
ARG PHP_VERSION
ARG PHP_VARIANT
ARG EXTENSION
ARG EXTENSION_VERSION

RUN --mount=type=bind,from=ghcr.io/kattokeskus/docker-php/ext/${EXTENSION}:${EXTENSION_VERSION}-php${PHP_VERSION}-${PHP_VARIANT},source=/,target=/ext \
    /ext/install.sh
```

## Tag Format

Extension images follow this naming pattern:

```
ghcr.io/kattokeskus/docker-php/ext/<extension>:<version>-php<php-version>-<variant>
```

Where:
- `<extension>` is the extension name (e.g., `redis`, `xdebug`)
- `<version>` is the extension versino (e.g. `6.3.0`, `8.4.14`)
- `<php-version>` is the PHP version (e.g., `8.3.27`, `8.4.14`)
- `<variant>` is the PHP image variant (e.g., `bookworm`, `trixie`)

Example:
```
ghcr.io/kattokeskus/docker-php/ext/redis:6.3.0-php8.3.27-bookworm
ghcr.io/kattokeskus/docker-php/ext/xdebug:8.4.14-php8.4.14-trixie
```

## Supported PHP Versions

- PHP 8.3
- PHP 8.4

## Available Extensions

- apcu
- bcmath
- bz2
- calendar
- curl
- ctype
- dba
- dom
- enchant
- exif
- ffi
- fileinfo
- filter
- ftp
- gd
- gettext
- gmp
- iconv
- imagick
- intl
- ldap
- mbstring
- mysqli
- opcache
- pcntl
- pdo
- pdo_dblib
- pdo_firebird
- pdo_mysql
- pdo_odbc
- pdo_pgsql
- pgsql
- phar
- posix
- redis
- session
- shmop
- simplexml
- snmp
- soap
- sockets
- sysvmsg
- sysvsem
- sysvshm
- tidy
- xdebug
- xhprof
- xml
- xmlreader
- xmlwriter
- xsl
- zip
