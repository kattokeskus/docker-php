variable "APCU_VERSION" {
    # renovate: datasource=custom.pecl depName=apcu versioning=semver
    default = "5.1.27"
}
variable "IMAGEMAGICK_VERSION" {
    # renovate: datasource=github-release depName=ImageMagick/ImageMagick versioning=semver
    default = "7.1.1-44"
}
variable "IMAGICK_VERSION" {
    # renovate: datasource=custom.pecl depName=imagick versioning=semver
    default = "3.8.0"
}
variable "IMAP_VERSION" {
    # renovate: datasource=custom.pecl depName=imap versioning=semver
    default = "1.0.3"
}
variable "REDIS_VERSION" {
    # renovate: datasource=custom.pecl depName=redis versioning=semver
    default = "6.3.0"
}
variable "VIPS_VERSION" {
    # renovate: datasource=github-releases depName=libvips/libvips versioning=semver
    default = "8.17.3"
}
variable "PHP_VIPS_VERSION" {
    # renovate: datasource=github-releases depName=libvips/php-vips versioning=semver
    default = "2.5.0"
}
variable "XDEBUG_VERSION" {
    # renovate: datasource=custom.pecl depName=xdebug versioning=semver
    default = "3.4.7"
}
variable "XHPROF_VERSION" {
    # renovate: datasource=custom.pecl depName=xhprof versioning=semver
    default = "2.3.10"
}
