variable "PHP_VERSION" {
}
variable "PHP_VARIANT" {
}

/***********************/
/* Dependency versions */
/***********************/
variable "APCU_VERSION" {
}
variable "IMAGEMAGICK_VERSION" {
}
variable "IMAGICK_VERSION" {
}
variable "IMAP_VERSION" {
}
variable "REDIS_VERSION" {
}
variable "VIPS_VERSION" {
}
variable "PHP_VIPS_VERSION" {
}
variable "XDEBUG_VERSION" {
}
variable "XHPROF_VERSION" {
}

target "php-version" {
    args = {
        PHP_VARIANT = "${PHP_VARIANT}"
        PHP_VERSION = "${PHP_VERSION}"
    }
}

/************************/
/* Extension base image */
/************************/
target "php-base-metadata" {
}
target "php-base" {
    inherits = ["php-version", "php-base-metadata"]
    context = "php"
    platforms = ["linux/amd64", "linux/arm64"]
    target = "base"
}
target "php-ext-base-metadata" {
}
target "php-ext-base" {
    inherits = ["php-version", "php-ext-base-metadata"]
    context = "php"
    platforms = ["linux/amd64", "linux/arm64"]
    target = "extension-build-base"
}

/********************/
/* Extension images */
/********************/
target "php-ext-metadata" {
}
target "php-ext" {
  inherits = ["php-version", "php-ext-metadata"]
  context = "php"
  platforms = ["linux/amd64", "linux/arm64"]
  args = {
    PHP_BASE_IMAGE = "php-base"
    PHP_EXT_BASE_IMAGE = "php-ext-base"
    #EXTENSION = ...
    #BUILDDEPS = ...
    #CONFIGURE = ...
    #MODULE = ...
    #DEPS = ...
  }
  depends_on = ["php-ext-base"]
  contexts = {
    php-base = "target:php-base"
    php-ext-base = "target:php-ext-base"
  }
  target = "php-ext"
}
target "php-ext-test" {
    inherits = ["php-ext"]
    target = "php-ext-test"
}

target "php-ext-apcu-metadata" {
}
target "php-ext-apcu" {
  inherits = ["php-version", "php-ext-apcu-metadata"]
  context = "extensions/apcu"
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64", "linux/arm64"]
  args = {
    PHP_EXT_BASE_IMAGE = "php-ext-base"
    PHP_BASE_IMAGE = "php-base"
    APCU_VERSION = "${APCU_VERSION}"
  }
  depends_on = ["php-ext-base"]
  contexts = {
    php-ext-base = "target:php-ext-base"
    php-base = "target:php-base"
  }
}
target "php-ext-apcu-test" {
    inherits = ["php-ext-apcu"]
    target = "test"
}

target "php-ext-bcmath-metadata" {
}
target "php-ext-bcmath" {
  inherits = ["php-ext", "php-ext-bcmath-metadata"]
  args = {
    EXTENSION = "bcmath"
  }
}
target "php-ext-bcmath-test" {
    inherits = ["php-ext-bcmath"]
    target = "php-ext-test"
}

target "php-ext-bz2-metadata" {
}
target "php-ext-bz2" {
  inherits = ["php-ext", "php-ext-bz2-metadata"]
  args = {
    EXTENSION = "bz2"
    BUILDDEPS = "libbz2-dev"
    DEPS = "libbz2-1.0"
  }
}
target "php-ext-bz2-test" {
    inherits = ["php-ext-bz2"]
    target = "php-ext-test"
}

target "php-ext-calendar-metadata" {
}
target "php-ext-calendar" {
  inherits = ["php-ext", "php-ext-calendar-metadata"]
  args = {
    EXTENSION = "calendar"
  }
}
target "php-ext-calendar-test" {
    inherits = ["php-ext-calendar"]
    target = "php-ext-test"
}

target "php-ext-ctype-metadata" {
}
target "php-ext-ctype" {
  inherits = ["php-ext", "php-ext-ctype-metadata"]
  args = {
    EXTENSION = "ctype"
  }
}
target "php-ext-ctype-test" {
    inherits = ["php-ext-ctype"]
    target = "php-ext-test"
}

target "php-ext-curl-metadata" {
}
target "php-ext-curl" {
  inherits = ["php-ext", "php-ext-curl-metadata"]
  args = {
    EXTENSION = "curl"
    BUILDDEPS = "libcurl4-openssl-dev"
    DEPS = "libcurl4"
  }
}
target "php-ext-curl-test" {
    inherits = ["php-ext-curl"]
    target = "php-ext-test"
}

target "php-ext-dba-metadata" {
}
target "php-ext-dba" {
  inherits = ["php-ext", "php-ext-dba-metadata"]
  args = {
    EXTENSION = "dba"
    BUILDDEPS = "libgdbm-dev liblmdb-dev"
    CONFIGURE = "--with-gdbm --with-lmdb"
    DEPS = "libgdbm6 liblmdb0"
  }
}
target "php-ext-dba-test" {
    inherits = ["php-ext-dba"]
    target = "php-ext-test"
}

target "php-ext-dom-metadata" {
}
target "php-ext-dom" {
  inherits = ["php-ext", "php-ext-dom-metadata"]
  args = {
    EXTENSION = "dom"
    BUILDDEPS = "libxml2-dev"
    DEPS = "libxml2"
  }
}
target "php-ext-dom-test" {
    inherits = ["php-ext-dom"]
    target = "php-ext-test"
}

target "php-ext-enchant-metadata" {
}
target "php-ext-enchant" {
  inherits = ["php-ext", "php-ext-enchant-metadata"]
  args = {
    EXTENSION = "enchant"
    BUILDDEPS = "libenchant-2-dev"
    DEPS = "libenchant-2-2"
  }
}
target "php-ext-enchant-test" {
    inherits = ["php-ext-enchant"]
    target = "php-ext-test"
}

target "php-ext-exif-metadata" {
}
target "php-ext-exif" {
  inherits = ["php-ext", "php-ext-exif-metadata"]
  args = {
    EXTENSION = "exif"
  }
}
target "php-ext-exif-test" {
    inherits = ["php-ext-exif"]
    target = "php-ext-test"
}

target "php-ext-ffi-metadata" {
}
target "php-ext-ffi" {
  inherits = ["php-ext", "php-ext-ffi-metadata"]
  args = {
    EXTENSION = "ffi"
    BUILDDEPS = "libffi-dev"
    DEPS = "libffi8"
    MODULE = "FFI"
  }
}
target "php-ext-ffi-test" {
    inherits = ["php-ext-ffi"]
    target = "php-ext-test"
}

target "php-ext-fileinfo-metadata" {
}
target "php-ext-fileinfo" {
  inherits = ["php-ext", "php-ext-fileinfo-metadata"]
  args = {
    EXTENSION = "fileinfo"
  }
}
target "php-ext-fileinfo-test" {
    inherits = ["php-ext-fileinfo"]
    target = "php-ext-test"
}

target "php-ext-filter-metadata" {
}
target "php-ext-filter" {
  inherits = ["php-ext", "php-ext-filter-metadata"]
  args = {
    EXTENSION = "filter"
  }
}
target "php-ext-filter-test" {
    inherits = ["php-ext-filter"]
    target = "php-ext-test"
}

target "php-ext-ftp-metadata" {
}
target "php-ext-ftp" {
  inherits = ["php-ext", "php-ext-ftp-metadata"]
  args = {
    EXTENSION = "ftp"
    EXTENSION_SCRATCH_IMAGE = "php-ext-pcntl"
  }
  depends_on = ["php-ext-pcntl"]
  contexts = {
    php-ext-pcntl = "target:php-ext-pcntl"
  }
}
target "php-ext-ftp-test" {
    inherits = ["php-ext-ftp"]
    target = "php-ext-test"
}

target "php-ext-gd-metadata" {
}
target "php-ext-gd" {
  inherits = ["php-ext", "php-ext-gd-metadata"]
  args = {
    EXTENSION = "gd"
    BUILDDEPS = "libfreetype6-dev libjpeg-dev libpng-dev libwebp-dev libavif-dev libxpm-dev"
    CONFIGURE = "--with-freetype --with-jpeg --with-webp --with-xpm"
    DEPS = "libfreetype6 libjpeg62 libpng16-16 libwebp7 ^libavif[0-9]+$ libxpm4"
  }
}
target "php-ext-gd-test" {
    inherits = ["php-ext-gd"]
    target = "php-ext-test"
}

target "php-ext-gettext-metadata" {
}
target "php-ext-gettext" {
  inherits = ["php-version", "php-ext-gettext-metadata"]
  context = "extensions/gettext"
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64", "linux/arm64"]
  args = {
    PHP_EXT_BASE_IMAGE = "php-ext-base"
    PHP_BASE_IMAGE = "php-base"
  }
  depends_on = ["php-ext-base"]
  contexts = {
    php-ext-base = "target:php-ext-base"
    php-base = "target:php-base"
  }
}
target "php-ext-gettext-test" {
    inherits = ["php-ext-gettext"]
    target = "test"
}

target "php-ext-gmp-metadata" {
}
target "php-ext-gmp" {
  inherits = ["php-ext", "php-ext-gmp-metadata"]
  args = {
    EXTENSION = "gmp"
    BUILDDEPS = "libgmp-dev"
    DEPS = "libgmp10"
  }
}
target "php-ext-gmp-test" {
    inherits = ["php-ext-gmp"]
    target = "php-ext-test"
}

target "php-ext-iconv-metadata" {
}
target "php-ext-iconv" {
  inherits = ["php-ext", "php-ext-iconv-metadata"]
  args = {
    EXTENSION = "iconv"
  }
}
target "php-ext-iconv-test" {
    inherits = ["php-ext-iconv"]
    target = "php-ext-test"
}

target "php-ext-imagick-metadata" {
}
target "php-ext-imagick" {
  inherits = ["php-version", "php-ext-imagick-metadata"]
  context = "extensions/imagick"
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64", "linux/arm64"]
  args = {
    PHP_EXT_BASE_IMAGE = "php-ext-base"
    PHP_BASE_IMAGE = "php-base"
    IMAGEMAGICK_VERSION = "${IMAGEMAGICK_VERSION}"
    IMAGICK_VERSION = "${IMAGICK_VERSION}"
    BUILDDEPS = "libgomp1 libbz2-dev libx11-dev libice-dev libxext-dev libxt-dev libzip-dev libzstd-dev libltdl-dev libfftw3-dev libdjvulibre-dev libfontconfig1-dev libfreetype6-dev libraqm-dev libgs-dev libgraphviz-dev libheif-dev libjbig-dev libjpeg-dev libjxl-dev liblcms2-dev libopenjp2-7-dev liblqr-1-0-dev liblzma-dev libopenexr-dev libpango1.0-dev libpng-dev libraw-dev librsvg2-dev libtiff-dev libwebp-dev libwmf-dev libxml2-dev libperl-dev fonts-dejavu fonts-urw-base35 ghostscript gsfonts zlib1g-dev libexif-dev"
    DEPS = "libgomp1 libbz2-1.0 libx11-6 libice6 libxext6 libxt6 ^libzip[0-9]+$ libzstd1 libltdl7 libfftw3-double3 libdjvulibre21 libfontconfig1 libfreetype6 libraqm0 libgs10 libgvc6 libheif1 libjbig0 libjpeg62 ^libjxl0.[0-9]+$ liblcms2-2 liblqr-1-0 liblzma5 libopenexr-3-1-30 libpango-1.0-0 libpng16-16 ^libraw[0-9]+(t64)?$ librsvg2-2 libtiff6 libwebp7 libwmf0.2-7 libxml2 libzstd1 ^libperl5.[0-9]+$ fonts-dejavu fonts-urw-base35 ghostscript gsfonts zlib1g libexif12 pkgconf"
  }
  depends_on = ["php-ext-base"]
  contexts = {
    php-ext-base = "target:php-ext-base"
    php-base = "target:php-base"
  }
}
target "php-ext-imagick-test" {
    inherits = ["php-ext-imagick"]
    target = "test"
}

target "php-ext-imap-metadata" {
}
target "php-ext-imap" {
  inherits = ["php-version", "php-ext-imap-metadata"]
  context = "extensions/imap"
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64", "linux/arm64"]
  args = {
    PHP_EXT_BASE_IMAGE = "php-ext-base"
    PHP_BASE_IMAGE = "php-base"
    IMAP_VERSION = "${IMAP_VERSION}"
  }
  depends_on = ["php-ext-base"]
  contexts = {
    php-ext-base = "target:php-ext-base"
    php-base = "target:php-base"
  }
}
target "php-ext-imap-test" {
    inherits = ["php-ext-imap"]
    target = "test"
}

target "php-ext-intl-metadata" {
}
target "php-ext-intl" {
  inherits = ["php-ext", "php-ext-intl-metadata"]
  args = {
    EXTENSION = "intl"
    BUILDDEPS = "libicu-dev"
    DEPS = "^libicu[0-9]+$"
  }
}
target "php-ext-intl-test" {
    inherits = ["php-ext-intl"]
    target = "php-ext-test"
}

target "php-ext-ldap-metadata" {
}
target "php-ext-ldap" {
  inherits = ["php-ext", "php-ext-ldap-metadata"]
  args = {
    EXTENSION = "ldap"
    BUILDDEPS = "libldap2-dev"
    DEPS = "^(libldap2|libldap-2.5-0)$"
  }
}
# TODO: Missing LDAP server
target "php-ext-ldap-test" {
    inherits = ["php-ext-ldap"]
    target = "php-ext-test"
}

target "php-ext-mbstring-metadata" {
}
target "php-ext-mbstring" {
  inherits = ["php-ext", "php-ext-mbstring-metadata"]
  args = {
    EXTENSION = "mbstring"
    BUILDDEPS = "libonig-dev"
    DEPS = "libonig5"
  }
}
target "php-ext-mbstring-test" {
    inherits = ["php-ext-mbstring"]
    target = "php-ext-test"
}

target "php-ext-mysqli-metadata" {
}
target "php-ext-mysqli" {
  inherits = ["php-version", "php-ext-mysqli-metadata"]
  context = "extensions/mysqli"
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64", "linux/arm64"]
  args = {
    PHP_EXT_BASE_IMAGE = "php-ext-base"
    PHP_BASE_IMAGE = "php-base"
  }
  depends_on = ["php-ext-base"]
  contexts = {
    php-ext-base = "target:php-ext-base"
    php-base = "target:php-base"
  }
}
target "php-ext-mysqli-test" {
    inherits = ["php-ext-mysqli"]
    target = "test"
}

target "php-ext-opcache-metadata" {
}
target "php-ext-opcache" {
  inherits = ["php-ext", "php-ext-opcache-metadata"]
  args = {
    EXTENSION = "opcache"
    MODULE = "Zend OPcache"
  }
}
target "php-ext-opcache-test" {
    inherits = ["php-ext-opcache"]
    target = "php-ext-test"
}

target "php-ext-pcntl-metadata" {
}
target "php-ext-pcntl" {
  inherits = ["php-ext", "php-ext-pcntl-metadata"]
  args = {
    EXTENSION = "pcntl"
    CONFIGURE = "--enable-pcntl"
  }
}
target "php-ext-pcntl-test" {
    inherits = ["php-ext-pcntl"]
    target = "php-ext-test"
}

target "php-ext-pdo-metadata" {
}
target "php-ext-pdo" {
  inherits = ["php-ext", "php-ext-pdo-metadata"]
  args = {
    EXTENSION = "pdo"
    MODULE = "PDO"
  }
}
target "php-ext-pdo-test" {
    inherits = ["php-ext-pdo"]
    target = "php-ext-test"
}

target "php-ext-pdo_dblib-metadata" {
}
target "php-ext-pdo_dblib" {
  inherits = ["php-ext", "php-ext-pdo_dblib-metadata"]
  args = {
    EXTENSION = "pdo_dblib"
    BUILDDEPS = "freetds-dev"
    DEPS = "freetds-common libct4 libsybdb5"
  }
}
# TODO: tests not working with multiple workers, unable to connect
target "php-ext-pdo_dblib-test" {
    inherits = ["php-ext-pdo_dblib"]
    target = "php-ext-test"
}

target "php-ext-pdo_firebird-metadata" {
}
target "php-ext-pdo_firebird" {
  inherits = ["php-ext", "php-ext-pdo_firebird-metadata"]
  args = {
    EXTENSION = "pdo_firebird"
    EXTENSION_SCRATCH_IMAGE = "php-ext-sockets"
    BUILDDEPS = "firebird-dev"
    MODULE = "PDO_Firebird"
    DEPS = "firebird3.0-common libfbclient2 libtommath1"
  }
  depends_on = ["php-ext-sockets"]
  contexts = {
    php-ext-sockets = "target:php-ext-sockets"
  }
}
# TODO: tests not working with multiple workers, PDO_FIREBIRD_TEST_DSN must be set
target "php-ext-pdo_firebird-test" {
    inherits = ["php-ext-pdo_firebird"]
    target = "php-ext-test"
}

target "php-ext-pdo_mysql-metadata" {
}
target "php-ext-pdo_mysql" {
  inherits = ["php-ext", "php-ext-pdo_mysql-metadata"]
  args = {
    EXTENSION = "pdo_mysql"
  }
}
# TODO: tests not working with multiple workers, No such file or directory
target "php-ext-pdo_mysql-test" {
    inherits = ["php-ext-pdo_mysql"]
    target = "php-ext-test"
}

target "php-ext-pdo_odbc-metadata" {
}
target "php-ext-pdo_odbc" {
  inherits = ["php-ext", "php-ext-pdo_odbc-metadata"]
  args = {
    EXTENSION = "pdo_odbc"
    BUILDDEPS = "unixodbc-dev"
    CONFIGURE = "--with-pdo-odbc=unixODBC,/usr"
    MODULE = "PDO_ODBC"
    DEPS = "unixodbc-common libodbc2"
  }
}
# TODO: tests not working with multiple workers
target "php-ext-pdo_odbc-test" {
    inherits = ["php-ext-pdo_odbc"]
    target = "php-ext-test"
}

target "php-ext-pdo_pgsql-metadata" {
}
target "php-ext-pdo_pgsql" {
  inherits = ["php-ext", "php-ext-pdo_pgsql-metadata"]
  args = {
    EXTENSION = "pdo_pgsql"
    BUILDDEPS = "libpq-dev"
    DEPS = "libpq5"
  }
}
# TODO: tests not working with multiple workers, connection refused
target "php-ext-pdo_pgsql-test" {
    inherits = ["php-ext-pdo_pgsql"]
    target = "php-ext-test"
}

target "php-ext-pdo_sqlite-metadata" {
}
target "php-ext-pdo_sqlite" {
  inherits = ["php-ext", "php-ext-pdo_sqlite-metadata"]
  args = {
    EXTENSION = "pdo_sqlite"
    BUILDDEPS = "libsqlite3-dev"
    DEPS = "libsqlite3-0"
  }
}
# TODO: tests not working with multiple workers
target "php-ext-pdo_sqlite-test" {
    inherits = ["php-ext-pdo_sqlite"]
    target = "php-ext-test"
}

target "php-ext-pgsql-metadata" {
}
target "php-ext-pgsql" {
  inherits = ["php-ext", "php-ext-pgsql-metadata"]
  args = {
    EXTENSION = "pgsql"
    BUILDDEPS = "libpq-dev"
    DEPS = "libpq5"
  }
}
# TODO: could not connect
target "php-ext-pgsql-test" {
    inherits = ["php-ext-pgsql"]
    target = "php-ext-test"
}

target "php-ext-phar-metadata" {
}
target "php-ext-phar" {
  inherits = ["php-ext", "php-ext-phar-metadata"]
  args = {
    EXTENSION = "phar"
    BUILDDEPS = "libssl-dev"
    MODULE = "Phar"
    DEPS = "libssl3"
  }
}
target "php-ext-phar-test" {
    inherits = ["php-ext-phar"]
    target = "php-ext-test"
}

target "php-ext-posix-metadata" {
}
target "php-ext-posix" {
  inherits = ["php-ext", "php-ext-posix-metadata"]
  args = {
    EXTENSION = "posix"
  }
}
target "php-ext-posix-test" {
    inherits = ["php-ext-posix"]
    target = "php-ext-test"
}

target "php-ext-readline-metadata" {
}
target "php-ext-readline" {
  inherits = ["php-ext", "php-ext-readline-metadata"]
  args = {
    EXTENSION = "readline"
    BUILDDEPS = "libedit-dev"
    DEPS = "libedit2"
  }
}
target "php-ext-readline-test" {
    inherits = ["php-ext-readline"]
    target = "php-ext-test"
}

target "php-ext-redis-metadata" {
}
target "php-ext-redis" {
  inherits = ["php-version", "php-ext-redis-metadata"]
  context = "extensions/redis"
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64", "linux/arm64"]
  args = {
    PHP_EXT_BASE_IMAGE = "php-ext-base"
    PHP_BASE_IMAGE = "php-base"
    REDIS_VERSION = "${REDIS_VERSION}"
  }
  depends_on = ["php-ext-base"]
  contexts = {
    php-ext-base = "target:php-ext-base"
    php-base = "target:php-base"
  }
}
target "php-ext-redis-test" {
    inherits = ["php-ext-redis"]
    target = "test"
}

target "php-ext-session-metadata" {
}
target "php-ext-session" {
  inherits = ["php-ext", "php-ext-session-metadata"]
  args = {
    EXTENSION = "session"
  }
}
target "php-ext-session-test" {
    inherits = ["php-ext-session"]
    target = "php-ext-test"
}

target "php-ext-shmop-metadata" {
}
target "php-ext-shmop" {
  inherits = ["php-ext", "php-ext-shmop-metadata"]
  args = {
    EXTENSION = "shmop"
  }
}
target "php-ext-shmop-test" {
    inherits = ["php-ext-shmop"]
    target = "php-ext-test"
}

target "php-ext-simplexml-metadata" {
}
target "php-ext-simplexml" {
  inherits = ["php-ext", "php-ext-simplexml-metadata"]
  args = {
    EXTENSION = "simplexml"
    BUILDDEPS = "libxml2-dev"
    DEPS = "libxml2"
    MODULE = "SimpleXML"
  }
}
target "php-ext-simplexml-test" {
    inherits = ["php-ext-simplexml"]
    target = "php-ext-test"
}

target "php-ext-snmp-metadata" {
}
target "php-ext-snmp" {
  inherits = ["php-ext", "php-ext-snmp-metadata"]
  args = {
    EXTENSION = "snmp"
    BUILDDEPS = "libsnmp-dev"
    DEPS = "libsnmp40"
  }
}
target "php-ext-snmp-test" {
    inherits = ["php-ext-snmp"]
    target = "php-ext-test"
}

target "php-ext-soap-metadata" {
}
target "php-ext-soap" {
  inherits = ["php-ext", "php-ext-soap-metadata"]
  args = {
    EXTENSION = "soap"
    BUILDDEPS = "libxml2-dev"
    DEPS = "libxml2"
  }
}
target "php-ext-soap-test" {
    inherits = ["php-ext-soap"]
    target = "php-ext-test"
}

target "php-ext-sockets-metadata" {
}
target "php-ext-sockets" {
  inherits = ["php-ext", "php-ext-sockets-metadata"]
  args = {
    EXTENSION = "sockets"
  }
}
target "php-ext-sockets-test" {
    inherits = ["php-ext-sockets"]
    target = "php-ext-test"
}

target "php-ext-sodium-metadata" {
}
target "php-ext-sodium" {
  inherits = ["php-ext", "php-ext-sodium-metadata"]
  args = {
    EXTENSION = "sodium"
    BUILDDEPS = "libsodium-dev"
    DEPS = "libsodium23"
  }
}
target "php-ext-sodium-test" {
    inherits = ["php-ext-sodium"]
    target = "php-ext-test"
}

target "php-ext-sysvmsg-metadata" {
}
target "php-ext-sysvmsg" {
  inherits = ["php-ext", "php-ext-sysvmsg-metadata"]
  args = {
    EXTENSION = "sysvmsg"
  }
}
target "php-ext-sysvmsg-test" {
    inherits = ["php-ext-sysvmsg"]
    target = "php-ext-test"
}

target "php-ext-sysvsem-metadata" {
}
target "php-ext-sysvsem" {
  inherits = ["php-ext", "php-ext-sysvsem-metadata"]
  args = {
    EXTENSION = "sysvsem"
  }
}
target "php-ext-sysvsem-test" {
    inherits = ["php-ext-sysvsem"]
    target = "php-ext-test"
}

target "php-ext-sysvshm-metadata" {
}
target "php-ext-sysvshm" {
  inherits = ["php-ext", "php-ext-sysvshm-metadata"]
  args = {
    EXTENSION = "sysvshm"
  }
}
target "php-ext-sysvshm-test" {
    inherits = ["php-ext-sysvshm"]
    target = "php-ext-test"
}

target "php-ext-tidy-metadata" {
}
target "php-ext-tidy" {
  inherits = ["php-ext", "php-ext-tidy-metadata"]
  args = {
    EXTENSION = "tidy"
    BUILDDEPS = "libtidy-dev"
    DEPS = "^(libtidy5deb1|libtidy[0-9]+)$"
  }
}
target "php-ext-tidy-test" {
    inherits = ["php-ext-tidy"]
    target = "php-ext-test"
}

target "php-ext-vips-metadata" {
}
target "php-ext-vips" {
  inherits = ["php-version", "php-ext-vips-metadata"]
  context = "extensions/vips"
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64", "linux/arm64"]
  args = {
    PHP_EXT_BASE_IMAGE = "php-ext-base"
    PHP_BASE_IMAGE = "php-base"
    VIPS_VERSION = "${VIPS_VERSION}"
    PHP_VIPS_VERSION = "${PHP_VIPS_VERSION}"
    EXTENSION = "vips"
    EXTENSION_SCRATCH_IMAGE = "php-ext-ffi"
    # Vips is not a PHP module but requires FFI to be enabled
    MODULE = "FFI"
    BUILDDEPS = "meson cmake qemu-user-static libglib2.0-dev libexpat1-dev libjemalloc-dev libarchive-dev libfftw3-dev libmagickcore-dev libmagickwand-dev libcfitsio-dev libimagequant-dev libcgif-dev libjpeg-dev libexif-dev libspng-dev libwebp-dev libpango1.0-dev librsvg2-2 libfontconfig-dev libopenslide-dev libmatio-dev liblcms2-dev libopenexr-dev libopenjp2-7-dev libhwy-dev liborc-0.4-dev libheif-dev libjxl-dev libpoppler-glib-dev bc"
    DEPS = "libglib2.0-0 libexpat1 libjemalloc2 libarchive13 libfftw3-double3 ^libmagickcore-[0-9]+.q16-[0-9]+$ ^libmagickwand-[0-9]+.q16-[0-9]+$ libcfitsio10 libimagequant0 libcgif0 libjpeg62 libexif12 libspng0 libwebp7 ^libpango-?1.0-0$ libpangocairo-1.0-0 librsvg2-dev libfontconfig1 libopenslide0 ^libmatio[0-9]+$ liblcms2-2 libopenexr-3-1-30 libhwy1 liborc-0.4-0 libheif1 ^libjxl0.[0-9]+$ libpoppler-glib8"
  }
  depends_on = ["php-ext-base", "php-ext-ffi"]
  contexts = {
    php-ext-base = "target:php-ext-base"
    php-base = "target:php-base"
    php-ext-ffi = "target:php-ext-ffi"
  }
}
target "php-ext-vips-test" {
    inherits = ["php-ext-vips"]
    target = "test"
}

target "php-ext-xdebug-metadata" {
}
target "php-ext-xdebug" {
  inherits = ["php-version", "php-ext-xdebug-metadata"]
  context = "extensions/xdebug"
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64", "linux/arm64"]
  args = {
    PHP_EXT_BASE_IMAGE = "php-ext-base"
    PHP_BASE_IMAGE = "php-base"
    XDEBUG_VERSION = "${XDEBUG_VERSION}"
  }
  depends_on = ["php-ext-base"]
  contexts = {
    php-ext-base = "target:php-ext-base"
    php-base = "target:php-base"
  }
}
target "php-ext-xdebug-test" {
    inherits = ["php-ext-xdebug"]
    target = "test"
}

target "php-ext-xhprof-metadata" {
}
target "php-ext-xhprof" {
  inherits = ["php-version", "php-ext-xhprof-metadata"]
  context = "extensions/xhprof"
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64", "linux/arm64"]
  args = {
    PHP_EXT_BASE_IMAGE = "php-ext-base"
    PHP_BASE_IMAGE = "php-base"
    XHPROF_VERSION = "${XHPROF_VERSION}"
  }
  depends_on = ["php-ext-base"]
  contexts = {
    php-ext-base = "target:php-ext-base"
    php-base = "target:php-base"
  }
}
target "php-ext-xhprof-test" {
    inherits = ["php-ext-xhprof"]
    target = "test"
}

target "php-ext-xml-metadata" {
}
target "php-ext-xml" {
  inherits = ["php-ext", "php-ext-xml-metadata"]
  args = {
    EXTENSION = "xml"
    BUILDDEPS = "libxml2-dev"
    DEPS = "libxml2"
  }
}
target "php-ext-xml-test" {
    inherits = ["php-ext-xml"]
    target = "php-ext-test"
}

target "php-ext-xmlreader-metadata" {
}
target "php-ext-xmlreader" {
  inherits = ["php-ext", "php-ext-xmlreader-metadata"]
  args = {
    EXTENSION = "xmlreader"
    BUILDDEPS = "libxml2-dev"
    DEPS = "libxml2"
    CONFIGURE = "CFLAGS=-I/usr/src/php"
  }
}
target "php-ext-xmlreader-test" {
    inherits = ["php-ext-xmlreader"]
    target = "php-ext-test"
}

target "php-ext-xmlwriter-metadata" {
}
target "php-ext-xmlwriter" {
  inherits = ["php-ext", "php-ext-xmlwriter-metadata"]
  args = {
    EXTENSION = "xmlwriter"
    BUILDDEPS = "libxml2-dev"
    DEPS = "libxml2"
  }
}
target "php-ext-xmlwriter-test" {
    inherits = ["php-ext-xmlwriter"]
    target = "php-ext-test"
}

target "php-ext-xsl-metadata" {
}
target "php-ext-xsl" {
  inherits = ["php-ext", "php-ext-xsl-metadata"]
  args = {
    EXTENSION = "xsl"
    BUILDDEPS = "libxslt1-dev"
    DEPS = "libxslt1.1"
  }
}
target "php-ext-xsl-test" {
    inherits = ["php-ext-xsl"]
    target = "php-ext-test"
}

target "php-ext-zip-metadata" {
}
target "php-ext-zip" {
  inherits = ["php-ext", "php-ext-zip-metadata"]
  args = {
    EXTENSION = "zip"
    BUILDDEPS = "libzip-dev"
    DEPS = "^libzip[0-9]+$"
  }
}
target "php-ext-zip-test" {
    inherits = ["php-ext-zip"]
    target = "php-ext-test"
}

/****************************/
/* Group for all extensions */
/****************************/
group "extensions" {
  targets = [
    "php-ext-apcu",
    "php-ext-bcmath",
    "php-ext-bz2",
    "php-ext-calendar",
    //"php-ext-curl",
    //"php-ext-ctype",
    "php-ext-dba",
    //"php-ext-dom",
    "php-ext-enchant",
    "php-ext-exif",
    "php-ext-ffi",
    //"php-ext-fileinfo",
    //"php-ext-filter",
    "php-ext-ftp",
    "php-ext-gd",
    "php-ext-gettext",
    "php-ext-gmp",
    //"php-ext-iconv",
    "php-ext-imagick",
    //"php-ext-imap",
    "php-ext-intl",
    "php-ext-ldap",
    //"php-ext-mbstring",
    "php-ext-mysqli",
    //"php-ext-opcache",
    "php-ext-pcntl",
    "php-ext-pdo",
    "php-ext-pdo_dblib",
    "php-ext-pdo_firebird",
    "php-ext-pdo_mysql",
    "php-ext-pdo_odbc",
    "php-ext-pdo_pgsql",
    "php-ext-pdo_sqlite",
    "php-ext-pgsql",
    //"php-ext-phar",
    //"php-ext-posix",
    //"php-ext-readline",
    "php-ext-redis",
    //"php-ext-session",
    "php-ext-shmop",
    //"php-ext-simplexml",
    "php-ext-snmp",
    "php-ext-soap",
    "php-ext-sockets",
    //"php-ext-sodium",
    "php-ext-sysvmsg",
    "php-ext-sysvsem",
    "php-ext-sysvshm",
    "php-ext-tidy",
    "php-ext-vips",
    "php-ext-xdebug",
    "php-ext-xhprof",
    //"php-ext-xml",
    //"php-ext-xmlreader",
    //"php-ext-xmlwriter",
    "php-ext-xsl",
    "php-ext-zip"
  ]
}

/********************************/
/* Group to test all extensions */
/********************************/
group "extensions-test" {
  targets = [
    "php-ext-apcu-test",
    "php-ext-bcmath-test",
    "php-ext-bz2-test",
    "php-ext-calendar-test",
    //"php-ext-curl-test",
    //"php-ext-ctype-test",
    "php-ext-dba-test",
    //"php-ext-dom-test",
    "php-ext-enchant-test",
    "php-ext-exif-test",
    "php-ext-ffi-test",
    //"php-ext-fileinfo-test",
    //"php-ext-filter-test",
    "php-ext-ftp-test",
    "php-ext-gd-test",
    "php-ext-gettext-test",
    "php-ext-gmp-test",
    //"php-ext-iconv-test",
    "php-ext-imagick-test",
    //"php-ext-imap-test",
    "php-ext-intl-test",
    "php-ext-ldap-test",
    //"php-ext-mbstring-test",
    "php-ext-mysqli-test",
    //"php-ext-opcache-test",
    "php-ext-pcntl-test",
    "php-ext-pdo-test",
    "php-ext-pdo_dblib-test",
    "php-ext-pdo_firebird-test",
    "php-ext-pdo_mysql-test",
    "php-ext-pdo_odbc-test",
    "php-ext-pdo_pgsql-test",
    "php-ext-pdo_sqlite-test",
    //"php-ext-phar-test",
    //"php-ext-posix-test",
    //"php-ext-readline-test",
    "php-ext-redis-test",
    //"php-ext-session-test",
    "php-ext-shmop-test",
    //"php-ext-simplexml-test",
    "php-ext-snmp-test",
    "php-ext-soap-test",
    "php-ext-sockets-test",
    //"php-ext-sodium-test",
    "php-ext-sysvmsg-test",
    "php-ext-sysvsem-test",
    "php-ext-sysvshm-test",
    "php-ext-tidy-test",
    "php-ext-vips-test",
    "php-ext-xdebug-test",
    "php-ext-xhprof-test",
    //"php-ext-xml-test",
    //"php-ext-xmlreader-test",
    //"php-ext-xmlwriter-test",
    "php-ext-xsl-test",
    "php-ext-zip-test"
  ]
}

/**************/
/* Base image */
/**************/
target "php-base" {
    inherits = ["php-version"]
    context = "php"
    target = "base"
    platforms = ["linux/amd64", "linux/arm64"]
}

/*********************************/
/* Intermediate extension images */
/*===============================*/
/*  1. apcu                      */
/*  2. bcmath                    */
/*  3. bz2                       */
/*  4. calendar                  */
/*  5. dba                       */
/*  6. enchant                   */
/*  7. exif                      */
/*  8. pcntl                     */
/*  9. ftp                       */
/* 10. gd                        */
/* 11. gettext                   */
/* 12. gmp                       */
/* 13. imagick                   */
/* 14. intl                      */
/* 15. ldap                      */
/* 16. mysqli                    */
/* 17. pdo_dblib                 */
/* 18. sockets                   */
/* 19. pdo_firebird              */
/* 20. pdo_mysql                 */
/* 21. pdo_odbc                  */
/* 22. pdo_pgsql                 */
/* 23. pgsql                     */
/* 24. redis                     */
/* 25. shmop                     */
/* 26. snmp                      */
/* 27. soap                      */
/* 28. sysvmsg                   */
/* 29. sysvsem                   */
/* 30. sysvshm                   */
/* 31. tidy                      */
/* 32. ffi                       */
/* 33. vips                      */
/* 34. xhprof                    */
/* 35. xsl                       */
/* 36. zip                       */
/* 37. xdebug                    */
/*********************************/
target "php-intermediate-base" {
    inherits = ["php-version"]
    context = "php"
    target = "install-extension"
    platforms = ["linux/amd64", "linux/arm64"]
    depends_on = ["php-base"]
}

target "php-intermediate-apcu" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-base = "target:php-base"
        php-ext-apcu = "target:php-ext-apcu"
    }
    args = {
        PHP_BASE_IMAGE = "php-base"
        EXTENSION_IMAGE = "php-ext-apcu"
    }
    depends_on = ["php-base", "php-ext-apcu"]
}

target "php-intermediate-bcmath" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-apcu = "target:php-intermediate-apcu"
        php-ext-bcmath = "target:php-ext-bcmath"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-apcu"
        EXTENSION_IMAGE = "php-ext-bcmath"
    }
    depends_on = ["php-intermediate-apcu", "php-ext-bcmath"]
}

target "php-intermediate-bz2" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-bcmath = "target:php-intermediate-bcmath"
        php-ext-bz2 = "target:php-ext-bz2"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-bcmath"
        EXTENSION_IMAGE = "php-ext-bz2"
    }
    depends_on = ["php-intermediate-bcmath", "php-ext-bz2"]
}

target "php-intermediate-calendar" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-bz2 = "target:php-intermediate-bz2"
        php-ext-calendar = "target:php-ext-calendar"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-bz2"
        EXTENSION_IMAGE = "php-ext-calendar"
    }
    depends_on = ["php-intermediate-bz2", "php-ext-calendar"]
}

target "php-intermediate-dba" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-calendar = "target:php-intermediate-calendar"
        php-ext-dba = "target:php-ext-dba"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-calendar"
        EXTENSION_IMAGE = "php-ext-dba"
    }
    depends_on = ["php-intermediate-calendar", "php-ext-dba"]
}

target "php-intermediate-enchant" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-dba = "target:php-intermediate-dba"
        php-ext-enchant = "target:php-ext-enchant"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-dba"
        EXTENSION_IMAGE = "php-ext-enchant"
    }
    depends_on = ["php-intermediate-dba", "php-ext-enchant"]
}

target "php-intermediate-exif" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-enchant = "target:php-intermediate-enchant"
        php-ext-exif = "target:php-ext-exif"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-enchant"
        EXTENSION_IMAGE = "php-ext-exif"
    }
    depends_on = ["php-intermediate-enchant", "php-ext-exif"]
}

target "php-intermediate-ftp" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-exif = "target:php-intermediate-exif"
        php-ext-ftp = "target:php-ext-ftp"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-exif"
        EXTENSION_IMAGE = "php-ext-ftp"
    }
    depends_on = ["php-intermediate-exif", "php-ext-ftp"]
}

target "php-intermediate-gd" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-ftp = "target:php-intermediate-ftp"
        php-ext-gd = "target:php-ext-gd"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-ftp"
        EXTENSION_IMAGE = "php-ext-gd"
    }
    depends_on = ["php-intermediate-ftp", "php-ext-gd"]
}

target "php-intermediate-gettext" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-gd = "target:php-intermediate-gd"
        php-ext-gettext = "target:php-ext-gettext"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-gd"
        EXTENSION_IMAGE = "php-ext-gettext"
    }
    depends_on = ["php-intermediate-gd", "php-ext-gettext"]
}

target "php-intermediate-gmp" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-gettext = "target:php-intermediate-gettext"
        php-ext-gmp = "target:php-ext-gmp"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-gettext"
        EXTENSION_IMAGE = "php-ext-gmp"
    }
    depends_on = ["php-intermediate-gettext", "php-ext-gmp"]
}

target "php-intermediate-imagick" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-gmp = "target:php-intermediate-gmp"
        php-ext-imagick = "target:php-ext-imagick"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-gmp"
        EXTENSION_IMAGE = "php-ext-imagick"
    }
    depends_on = ["php-intermediate-gmp", "php-ext-imagick"]
}

target "php-intermediate-intl" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-imagick = "target:php-intermediate-imagick"
        php-ext-intl = "target:php-ext-intl"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-imagick"
        EXTENSION_IMAGE = "php-ext-intl"
    }
    depends_on = ["php-intermediate-imagick", "php-ext-intl"]
}

target "php-intermediate-ldap" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-intl = "target:php-intermediate-intl"
        php-ext-ldap = "target:php-ext-ldap"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-intl"
        EXTENSION_IMAGE = "php-ext-ldap"
    }
    depends_on = ["php-intermediate-intl", "php-ext-ldap"]
}

target "php-intermediate-mysqli" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-ldap = "target:php-intermediate-ldap"
        php-ext-mysqli = "target:php-ext-mysqli"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-ldap"
        EXTENSION_IMAGE = "php-ext-mysqli"
    }
    depends_on = ["php-intermediate-ldap", "php-ext-mysqli"]
}

# Already installed as php-ext-ftp dependency
# target "php-intermediate-pcntl" {
#     inherits = ["php-intermediate-base"]
#     contexts = {
#         php-intermediate-mysqli = "target:php-intermediate-mysqli"
#         php-ext-pcntl = "target:php-ext-pcntl"
#     }
#     args = {
#         PHP_BASE_IMAGE = "php-intermediate-mysqli"
#         EXTENSION_IMAGE = "php-ext-pcntl"
#     }
#     depends_on = ["php-intermediate-mysqli", "php-ext-pcntl"]
# }

target "php-intermediate-pdo_dblib" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-mysqli = "target:php-intermediate-mysqli"
        php-ext-pdo_dblib = "target:php-ext-pdo_dblib"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-mysqli"
        EXTENSION_IMAGE = "php-ext-pdo_dblib"
    }
    depends_on = ["php-intermediate-mysqli", "php-ext-pdo_dblib"]
}

target "php-intermediate-pdo_firebird" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-pdo_dblib = "target:php-intermediate-pdo_dblib"
        php-ext-pdo_firebird = "target:php-ext-pdo_firebird"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-pdo_dblib"
        EXTENSION_IMAGE = "php-ext-pdo_firebird"
    }
    depends_on = ["php-intermediate-pdo_dblib", "php-ext-pdo_firebird"]
}

target "php-intermediate-pdo_mysql" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-pdo_firebird = "target:php-intermediate-pdo_firebird"
        php-ext-pdo_mysql = "target:php-ext-pdo_mysql"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-pdo_firebird"
        EXTENSION_IMAGE = "php-ext-pdo_mysql"
    }
    depends_on = ["php-intermediate-pdo_firebird", "php-ext-pdo_mysql"]
}

target "php-intermediate-pdo_odbc" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-pdo_mysql = "target:php-intermediate-pdo_mysql"
        php-ext-pdo_odbc = "target:php-ext-pdo_odbc"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-pdo_mysql"
        EXTENSION_IMAGE = "php-ext-pdo_odbc"
    }
    depends_on = ["php-intermediate-pdo_mysql", "php-ext-pdo_odbc"]
}

target "php-intermediate-pdo_pgsql" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-pdo_odbc = "target:php-intermediate-pdo_odbc"
        php-ext-pdo_pgsql = "target:php-ext-pdo_pgsql"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-pdo_odbc"
        EXTENSION_IMAGE = "php-ext-pdo_pgsql"
    }
    depends_on = ["php-intermediate-pdo_odbc", "php-ext-pdo_pgsql"]
}

target "php-intermediate-pgsql" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-pdo_pgsql = "target:php-intermediate-pdo_pgsql"
        php-ext-pgsql = "target:php-ext-pgsql"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-pdo_pgsql"
        EXTENSION_IMAGE = "php-ext-pgsql"
    }
    depends_on = ["php-intermediate-pdo_pgsql", "php-ext-pgsql"]
}

target "php-intermediate-redis" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-pgsql = "target:php-intermediate-pgsql"
        php-ext-redis = "target:php-ext-redis"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-pgsql"
        EXTENSION_IMAGE = "php-ext-redis"
    }
    depends_on = ["php-intermediate-pgsql", "php-ext-redis"]
}

target "php-intermediate-shmop" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-redis = "target:php-intermediate-redis"
        php-ext-shmop = "target:php-ext-shmop"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-redis"
        EXTENSION_IMAGE = "php-ext-shmop"
    }
    depends_on = ["php-intermediate-redis", "php-ext-shmop"]
}

target "php-intermediate-snmp" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-shmop = "target:php-intermediate-shmop"
        php-ext-snmp = "target:php-ext-snmp"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-shmop"
        EXTENSION_IMAGE = "php-ext-snmp"
    }
    depends_on = ["php-intermediate-shmop", "php-ext-snmp"]
}

target "php-intermediate-soap" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-snmp = "target:php-intermediate-snmp"
        php-ext-soap = "target:php-ext-soap"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-snmp"
        EXTENSION_IMAGE = "php-ext-soap"
    }
    depends_on = ["php-intermediate-snmp", "php-ext-soap"]
}

# Already installed as php-ext-pdo_firebird dependency
# target "php-intermediate-sockets" {
#     inherits = ["php-intermediate-base"]
#     contexts = {
#         php-intermediate-soap = "target:php-intermediate-soap"
#         php-ext-sockets = "target:php-ext-sockets"
#     }
#     args = {
#         PHP_BASE_IMAGE = "php-intermediate-soap"
#         EXTENSION_IMAGE = "php-ext-sockets"
#     }
#     depends_on = ["php-intermediate-soap", "php-ext-sockets"]
# }

target "php-intermediate-sysvmsg" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-snmp = "target:php-intermediate-snmp"
        php-ext-sysvmsg = "target:php-ext-sysvmsg"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-snmp"
        EXTENSION_IMAGE = "php-ext-sysvmsg"
    }
    depends_on = ["php-intermediate-snmp", "php-ext-sysvmsg"]
}

target "php-intermediate-sysvsem" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-sysvmsg = "target:php-intermediate-sysvmsg"
        php-ext-sysvsem = "target:php-ext-sysvsem"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-sysvmsg"
        EXTENSION_IMAGE = "php-ext-sysvsem"
    }
    depends_on = ["php-intermediate-sysvmsg", "php-ext-sysvsem"]
}

target "php-intermediate-sysvshm" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-sysvsem = "target:php-intermediate-sysvsem"
        php-ext-sysvshm = "target:php-ext-sysvshm"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-sysvsem"
        EXTENSION_IMAGE = "php-ext-sysvshm"
    }
    depends_on = ["php-intermediate-sysvsem", "php-ext-sysvshm"]
}

target "php-intermediate-tidy" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-sysvshm = "target:php-intermediate-sysvshm"
        php-ext-tidy = "target:php-ext-tidy"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-sysvshm"
        EXTENSION_IMAGE = "php-ext-tidy"
    }
    depends_on = ["php-intermediate-sysvshm", "php-ext-tidy"]
}

target "php-intermediate-vips" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-tidy = "target:php-intermediate-tidy"
        php-ext-vips = "target:php-ext-vips"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-tidy"
        EXTENSION_IMAGE = "php-ext-vips"
    }
    depends_on = ["php-intermediate-tidy", "php-ext-vips"]
}

target "php-intermediate-xhprof" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-vips = "target:php-intermediate-vips"
        php-ext-xhprof = "target:php-ext-xhprof"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-vips"
        EXTENSION_IMAGE = "php-ext-xhprof"
    }
    depends_on = ["php-intermediate-vips", "php-ext-xhprof"]
}

target "php-intermediate-xsl" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-xhprof = "target:php-intermediate-xhprof"
        php-ext-xsl = "target:php-ext-xsl"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-xhprof"
        EXTENSION_IMAGE = "php-ext-xsl"
    }
    depends_on = ["php-intermediate-xhprof", "php-ext-xsl"]
}

target "php-intermediate-zip" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-xsl = "target:php-intermediate-xsl"
        php-ext-zip = "target:php-ext-zip"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-xsl"
        EXTENSION_IMAGE = "php-ext-zip"
    }
    depends_on = ["php-intermediate-xsl", "php-ext-zip"]
}

target "php-intermediate-xdebug" {
    inherits = ["php-intermediate-base"]
    contexts = {
        php-intermediate-zip = "target:php-intermediate-zip"
        php-ext-xdebug = "target:php-ext-xdebug"
    }
    args = {
        PHP_BASE_IMAGE = "php-intermediate-zip"
        EXTENSION_IMAGE = "php-ext-xdebug"
    }
    depends_on = ["php-intermediate-zip", "php-ext-xdebug"]
}

/********************************/
/* Final images with extensions */
/********************************/
/* 1. php (without xdebug)      */
/* 2. php-debug (with xdebug)   */
/********************************/
target "php-metadata" {
}
target "php" {
    inherits = ["php-version", "php-metadata"]
    context = "php"
    target = "dummy"
    platforms = ["linux/amd64", "linux/arm64"]
    contexts = {
        php-intermediate-zip = "target:php-intermediate-zip"
    }
    args = {
        IMAGE = "php-intermediate-zip"
    }
    depends_on = ["php-intermediate-zip"]
}

target "php-debug-metadata" {
}
target "php-debug" {
    inherits = ["php-version", "php-debug-metadata"]
    context = "php"
    target = "dummy"
    platforms = ["linux/amd64", "linux/arm64"]
    contexts = {
        php-intermediate-xdebug = "target:php-intermediate-xdebug"
    }
    args = {
        IMAGE = "php-intermediate-xdebug"
    }
    depends_on = ["php-intermediate-xdebug"]
}
