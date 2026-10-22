variable "PHP_VERSION" {
    # renovate: datasource=docker depName=docker.io/library/php versioning=semver
    default = "8.5.12"
}
# docker.io/library/php has no 8.5.12 yet, remove once it does
variable "PHP_SOURCE" {
    default = "https://github.com/docker-library/php.git#e3eaff845f7a9f7259c31da54dce0320b47a3bbd:8.5/${PHP_VARIANT}"
}
