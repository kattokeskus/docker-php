variable "PHP_VERSION" {
    # renovate: datasource=docker depName=library/php versioning=semver
    default = "8.3.28"
}
variable "PHP_VARIANT" {
    default = "bookworm"
}
