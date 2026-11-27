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

> **Note:** Check [vars-8.4.hcl](vars-8.4.hcl), [vars-8.5.hcl](vars-8.5.hcl) or [vars-8.6.hcl](vars-8.6.hcl) for exact PHP versions as they are updated by Renovate. The build variant is defined in [php-trixie.hcl](php-trixie.hcl).

For the thread safe (ZTS) PHP images, use the `-zts` extension images:

```dockerfile
FROM php:${PHP_VERSION}-zts-${PHP_VARIANT}
# ...
RUN --mount=type=bind,from=ghcr.io/kattokeskus/docker-php/ext/${EXTENSION}:${EXTENSION_VERSION}-php${PHP_VERSION}-${PHP_VARIANT}-zts,source=/,target=/ext \
    /ext/install.sh
```

From PHP 8.6 the default official images are ZTS, so the extension images without a suffix are ZTS too. For the NTS variant of the official PHP 8.6 image, use the `-nts` extension images:

```dockerfile
FROM php:${PHP_VERSION}-nts-${PHP_VARIANT}
# ...
RUN --mount=type=bind,from=ghcr.io/kattokeskus/docker-php/ext/${EXTENSION}:${EXTENSION_VERSION}-php${PHP_VERSION}-${PHP_VARIANT}-nts,source=/,target=/ext \
    /ext/install.sh
```

vips is not built for zts: php-vips custom sources and targets crash there, as libvips calls their PHP callbacks from its own threads.

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
- `<thread-safety>` is `nts` for the `php:<php-version>-<variant>` images up to PHP 8.5 and the `php:<php-version>-nts-<variant>` images from PHP 8.6, or `zts` for the thread safe `php:<php-version>-zts-<variant>` images. Tags without it have the thread safety of the default `php:<php-version>-<variant>` image: `nts` up to PHP 8.5, `zts` from PHP 8.6.

Each tag comes in three forms: without a suffix, with `-nts` and with `-zts`. The tag without a suffix points to the same image as `-nts` up to PHP 8.5 and as `-zts` from PHP 8.6.

Example:
```
ghcr.io/kattokeskus/docker-php/ext/redis:6.3.0-php8.4.17-trixie
ghcr.io/kattokeskus/docker-php/ext/redis:6.3.0-php8.4.17-trixie-nts
ghcr.io/kattokeskus/docker-php/ext/redis:6.3.0-php8.4.17-trixie-zts
ghcr.io/kattokeskus/docker-php/ext/xdebug:3.5.0-php8.5.1-trixie-zts
ghcr.io/kattokeskus/docker-php/ext/redis:6.4.0RC1-php8.6.0-trixie
ghcr.io/kattokeskus/docker-php/ext/redis:6.4.0RC1-php8.6.0-trixie-nts
```

## PHP-FPM Images

PHP-FPM images for the same PHP versions, usable in place of `php:<php-version>-fpm-<variant>`. Like the official PHP-FPM images, they have the default thread safety only: `nts` up to PHP 8.5, `zts` from PHP 8.6. Use the extension images without a suffix with them:

```
ghcr.io/kattokeskus/docker-php/php-fpm:<php-version>-<variant>
ghcr.io/kattokeskus/docker-php/php-fpm:<minor>-<variant>
```

## Supported PHP Versions

- PHP 8.4
- PHP 8.5
- PHP 8.6

### PHP 8.6

- The default official PHP 8.6 images (cli, fpm, apache) are built thread-safe (ZTS), so the PHP 8.6 images without a thread safety suffix are ZTS, including the PHP-FPM image.
- The NTS images are built on the official NTS variant `php:<php-version>-nts-<variant>` and tagged `-nts`. That variant exists for the CLI image only, so there is no NTS PHP-FPM image for PHP 8.6.
- The official PHP 8.6 images no longer include `mbstring`, so it is available as an extension image for PHP 8.6.
- Until stable releases support PHP 8.6, [vars-8.6.hcl](vars-8.6.hcl) pins pre-release versions of `apcu`, `imagick`, `redis`, `spx` and `xdebug`.

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
- mbstring (PHP 8.6)
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
- spx
- sysvmsg
- sysvsem
- sysvshm
- tidy
- vips (nts only)
- xdebug
- xhprof
- xsl
- zip
