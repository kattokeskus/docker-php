#!/bin/bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <archive> <platform>" >&2
    exit 1
fi

archive="$1"
platform="$2"
os="${platform%%/*}"
arch="${platform##*/}"

if [[ ! -f "$archive" ]]; then
    echo "Archive $archive not found" >&2
    exit 1
fi

manifest="$(tar -xOf "$archive" index.json)"

target_manifest="$(echo "$manifest" | jq -r ".manifests[] | select(.platform.os == \"${os}\" and .platform.architecture == \"${arch}\")")"

if [[ -z "$target_manifest" ]]; then
    echo "Manifest does not contain platform: ${platform}" >&2
    exit 1
fi

# Verify manifest values
if ! echo "$target_manifest" \
  | jq -r ".platform.os" \
  | grep -q "^${os}$"
then
    echo "Manifest os does not match: ${os}" >&2
    exit 1
fi

if ! echo "$target_manifest" \
  | jq -r ".platform.architecture" \
  | grep -q "^${arch}$"
then
    echo "Manifest architecture does not match: ${arch}" >&2
    exit 1
fi

echo "$(echo "$target_manifest" | jq -r ".digest")"