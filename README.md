# Prebuilt PHP Extensions

This project provides prebuilt PHP extension images that can be installed into PHP base images.

## Table of Contents

- [Using Prebuilt Extensions](#using-prebuilt-extensions)
- [Tag Format](#tag-format)
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

> **Note:** Check [vars-8.3.hcl](vars-8.3.hcl), [vars-8.4.hcl](vars-8.4.hcl), or [vars-8.5.hcl](vars-8.5.hcl) for exact PHP versions as they are updated by Renovate. Build variants are defined in [php-trixie.hcl](php-trixie.hcl) and [php-bookworm.hcl](php-bookworm.hcl).

## Tag Format

Extension images follow this naming pattern:

```
ghcr.io/kattokeskus/docker-php/ext/<extension>:<version>-php<php-version>-<variant>
```

Where:
- `<extension>` is the extension name (e.g., `redis`, `xdebug`)
- `<version>` is the extension version (e.g., `6.3.0`, `3.5.0`)
- `<php-version>` is the PHP version (e.g., `8.4.17`, `8.5.1`)
- `<variant>` is the PHP image variant (e.g., `bookworm`, `trixie`)

Example:
```
ghcr.io/kattokeskus/docker-php/ext/redis:6.3.0-php8.4.17-bookworm
ghcr.io/kattokeskus/docker-php/ext/xdebug:3.5.0-php8.5.1-trixie
```

## Supported PHP Versions

- PHP 8.3
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
