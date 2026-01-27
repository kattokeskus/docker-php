variable "PHP_VERSION" {
    # renovate: datasource=docker depName=library/php versioning=semver
    default = "8.3.30"
}
variable "PHP_VARIANT" {
    default = "bookworm"
}
