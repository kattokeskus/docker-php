variable "PHP_VERSION" {
    # renovate: datasource=docker depName=docker.io/library/php versioning=semver
    default = "8.6.0"
}

# The default official PHP 8.6 images (cli, fpm, apache) are ZTS. NTS is the
# CLI-only php:<version>-nts-<variant> variant, so there is no NTS php-fpm.
variable "PHP_DEFAULT_THREAD_SAFETY" {
    default = "zts"
}

# Extension versions for PHP 8.6 that override vars.hcl. No stable release of
# these supports PHP 8.6 yet. Remove each override once vars.hcl has a release
# that builds on PHP 8.6. A git commit is fetched from GitHub instead of PECL.

# apcu 5.1.28 fails to build, the PHP 8.6 fixes are only on master
variable "APCU_VERSION" {
    default = "fb2c942552a3f5dab7f4dea4afb5cf0831222c57"
}
# imagick 3.8.1 uses XtOffsetOf, removed in PHP 8.6, fixed only on master
variable "IMAGICK_VERSION" {
    default = "55ed2e9fda264395636a2e27e51f31673f5566ab"
}
# redis 6.3.0 uses XtOffsetOf and INI_INT, removed in PHP 8.6
variable "REDIS_VERSION" {
    default = "6.4.0RC1"
}
# xdebug 3.5 refuses PHP 8.6, 3.6.0alpha1 is tagged on GitHub but not on PECL
variable "XDEBUG_VERSION" {
    default = "3.6.0alpha1"
}
# spx 0.4.22 and master stop at PHP 8.5, the unreleased v0.5 branch (0.5.0-dev) supports 8.6
variable "SPX_VERSION" {
    default = "ef1155c0daffd99ebc4ef596633b0d7d699f9e12"
}
