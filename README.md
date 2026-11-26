# Prebuilt PHP Extensions

This project provides prebuilt PHP extension images that can be installed into PHP base images.

## Table of Contents

- [Using Prebuilt Extensions](#using-prebuilt-extensions)
- [Tag Format](#tag-format)
- [PHP-FPM Images](#php-fpm-images)
- [Supported PHP Versions](#supported-php-versions)
- [Available Extensions](#available-extensions)

## Using Prebuilt Extensions

To install a prebuilt extension into your PHP image, mount the extension image and run its install script:

```dockerfile
ARG PHP_VERSION=8.4.17
ARG PHP_VARIANT=trixie
ARG EXTENSION=redis
ARG EXTENSION_VERSION=6.3.0
FROM php:${PHP_VERSION}-${PHP_VARIANT}
ARG PHP_VERSION
ARG PHP_VARIANT
ARG EXTENSION
ARG EXTENSION_VERSION

RUN --mount=type=bind,from=ghcr.io/kattokeskus/docker-php/ext/${EXTENSION}:${EXTENSION_VERSION}-php${PHP_VERSION}-${PHP_VARIANT},source=/,target=/ext \
    /ext/install.sh
```

> **Note:** Check [vars-8.4.hcl](vars-8.4.hcl) or [vars-8.5.hcl](vars-8.5.hcl) for exact PHP versions as they are updated by Renovate. The build variant is defined in [php-trixie.hcl](php-trixie.hcl).

For the thread safe (ZTS) PHP images, use the `-zts` extension images:

```dockerfile
FROM php:${PHP_VERSION}-zts-${PHP_VARIANT}
# ...
RUN --mount=type=bind,from=ghcr.io/kattokeskus/docker-php/ext/${EXTENSION}:${EXTENSION_VERSION}-php${PHP_VERSION}-${PHP_VARIANT}-zts,source=/,target=/ext \
    /ext/install.sh
```

## Tag Format

Extension images follow this naming pattern:

```
ghcr.io/kattokeskus/docker-php/ext/<extension>:<version>-php<php-version>-<variant>[-<thread-safety>]
ghcr.io/kattokeskus/docker-php/ext/<extension>:php<php-version>-<variant>[-<thread-safety>]
ghcr.io/kattokeskus/docker-php/ext/<extension>:php<minor>-<variant>[-<thread-safety>]
```

Where:
- `<extension>` is the extension name (e.g., `redis`, `xdebug`)
- `<version>` is the extension version (e.g., `6.3.0`, `3.5.0`)
- `<php-version>` is the PHP version (e.g., `8.4.17`, `8.5.1`)
- `<minor>` is the PHP minor version (e.g., `8.4`, `8.5`)
- `<variant>` is the PHP image variant (`trixie`)
- `<thread-safety>` is `nts` for the `php:<php-version>-<variant>` images or `zts` for the thread safe `php:<php-version>-zts-<variant>` images. Tags without it are `nts`.

Each tag comes in three forms: without a suffix and with `-nts`, which point to the same nts image, and with `-zts` for the zts image.

Example:
```
ghcr.io/kattokeskus/docker-php/ext/redis:6.3.0-php8.4.17-trixie
ghcr.io/kattokeskus/docker-php/ext/redis:6.3.0-php8.4.17-trixie-nts
ghcr.io/kattokeskus/docker-php/ext/redis:6.3.0-php8.4.17-trixie-zts
ghcr.io/kattokeskus/docker-php/ext/xdebug:3.5.0-php8.5.1-trixie-zts
```

## PHP-FPM Images

PHP-FPM images for the same PHP versions, usable in place of `php:<php-version>-fpm-<variant>`. They are nts only, as there are no zts PHP-FPM images:

```
ghcr.io/kattokeskus/docker-php/php-fpm:<php-version>-<variant>
ghcr.io/kattokeskus/docker-php/php-fpm:<minor>-<variant>
```

## Supported PHP Versions

- PHP 8.4
- PHP 8.5

## Available Extensions

- apcu
- bcmath
- bz2
- calendar
- dba
- enchant
- exif
- ffi
- ftp
- gd
- gettext
- gmp
- imagick
- intl
- ldap
- mysqli
- pcntl
- pdo
- pdo_dblib
- pdo_firebird
- pdo_mysql
- pdo_odbc
- pdo_pgsql
- pdo_sqlite
- pgsql
- redis
- shmop
- snmp
- soap
- sockets
- sysvmsg
- sysvsem
- sysvshm
- tidy
- vips
- xdebug
- xhprof
- xsl
- zip
