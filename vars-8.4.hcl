variable "PHP_VERSION" {
    # renovate: datasource=docker depName=docker.io/library/php versioning=semver
    default = "8.4.16"
}
variable "PHP_VARIANT" {
    default = "bookworm"
}
