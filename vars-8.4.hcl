variable "PHP_VERSION" {
    # renovate: datasource=docker depName=docker.io/library/php versioning=semver
    default = "8.4.28"
}

# Comma-separated extensions that are not built for PHP 8.4.
# mbstring is built into the official PHP 8.4 images.
variable "EXCLUDED_EXTENSIONS" {
    default = "mbstring"
}
