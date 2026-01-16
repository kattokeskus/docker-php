variable "PHP_VERSION" {
    # renovate: datasource=docker depName=docker.io/library/php versioning=semver
    default = "8.5.1"
}
variable "PHP_VARIANT" {
    default = "bookworm"
}
