#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null
cd "$SCRIPT_DIR/.."

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <php-version> <php-variant> [<extension>]"
    exit 1
fi

INPUT_PHP_VERSION="$1"
PHP_VARIANT="$2"
EXTENSION="${3:-}"

if [ ! -f "vars-${INPUT_PHP_VERSION}.hcl" ]; then
    echo "vars-${INPUT_PHP_VERSION}.hcl not found"
    exit 1
fi

PHP_VERSION=$(./.github/hcl_get_variable.sh "vars-${INPUT_PHP_VERSION}.hcl" PHP_VERSION)

PHP_BAKE="$(PHP_VERSION="${PHP_VERSION}" PHP_VARIANT="${PHP_VARIANT}" \
    docker buildx bake --print \
    -f docker-bake.hcl \
    -f "vars.hcl" \
    -f "vars-${INPUT_PHP_VERSION}.hcl" \
    php-base php-ext-base 2>/dev/null)"

# Parse context
context="$(echo "$PHP_BAKE" | jq -r ".target.\"php-base\".context")"
ext_context="$(echo "$PHP_BAKE" | jq -r ".target.\"php-ext-base\".context")"

if [[ -z "$context" ]] || [[ -z "$ext_context" ]]; then
    echo "Context not found"
    exit 1
fi
if [[ "$context" != "$ext_context" ]]; then
    echo "Context and ext context are different"
    exit 1
fi
if [[ ! -d "$context" ]]; then
    echo "Context directory does not exist"
    exit 1
fi

# Add context hash to bake output
context_hash="$(find "$context" -type f -exec cat {} + | sha256sum | cut -d' ' -f1)"
PHP_BAKE="$(echo "$PHP_BAKE" | jq -r --arg context_hash "$context_hash" '. + {context_hash: $context_hash}')"

BUILD_HASH_FULL="$(echo "$PHP_BAKE" | sha256sum | cut -d' ' -f1)"

BUILD_HASH="${BUILD_HASH_FULL:0:7}"

if [[ -n "$EXTENSION" ]]; then
    echo "$BUILD_HASH"
    exit 0
fi

ext_version_var=$(echo "$EXTENSION" | tr '[:lower:]' '[:upper:]')_VERSION
ext_version="$(./.github/hcl_get_variable.sh vars.hcl $ext_version_var 2>/dev/null || true)"
if [[ -z "$ext_version" ]]; then
    ext_version_var="PHP_VERSION"
    ext_version="${PHP_VERSION}"
fi
export $ext_version_var="$ext_version"

EXTENSION_BAKE="$(EXTENSION="$EXTENSION" PHP_VERSION="$PHP_VERSION" PHP_VARIANT="$PHP_VARIANT" \
    docker buildx bake --print \
    -f docker-bake.hcl \
    -f "vars.hcl" \
    -f "vars-${INPUT_PHP_VERSION}.hcl" \
    php-ext-${EXTENSION} php-ext-${EXTENSION}-test 2>/dev/null)"

# Parse context
context="$(echo "$EXTENSION_BAKE" | jq -r ".target.\"php-ext-${EXTENSION}\".context")"
test_context="$(echo "$EXTENSION_BAKE" | jq -r ".target.\"php-ext-${EXTENSION}-test\".context")"

if [[ -z "$context" ]] || [[ -z "$test_context" ]]; then
    echo "Context not found"
    exit 1
fi
if [[ "$context" != "$test_context" ]]; then
    echo "Context and test context are different"
    exit 1
fi
if [[ ! -d "$context" ]]; then
    echo "Context directory does not exist"
    exit 1
fi

# Add build hash and build context hash to bake output
context_hash="$(find "$context" -type f -exec cat {} + | sha256sum | cut -d' ' -f1)"
EXTENSION_BAKE="$(echo "$EXTENSION_BAKE" | jq -r --arg context_hash "$context_hash" --arg build_hash "$BUILD_HASH" '. + {context_hash: $context_hash, build_hash: $build_hash}')"

EXTENSION_BUILD_HASH_FULL="$(echo "$EXTENSION_BAKE" | sha256sum | cut -d' ' -f1)"

EXTENSION_BUILD_HASH="${EXTENSION_BUILD_HASH_FULL:0:7}"

echo "$EXTENSION_BUILD_HASH"