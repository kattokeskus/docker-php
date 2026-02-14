variable "PHP_VERSION" {
    # renovate: datasource=docker depName=docker.io/library/php versioning=semver
    default = "8.4.18"
}
variable "PHP_VARIANT" {
    default = "bookworm"
}
