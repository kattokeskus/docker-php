variable "PHP_VERSION" {
    # renovate: datasource=docker depName=library/php versioning=semver
    default = "8.3.29"
}
variable "PHP_VARIANT" {
    default = "bookworm"
}
