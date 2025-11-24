#!/bin/bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <output-archive> <archive> [archive...]" >&2
    exit 1
fi

output_archive="$1"

if [[ -e "$output_archive" ]]; then
    echo "Output archive $output_archive already exists" >&2
    exit 1
fi

manifests=()

if [[ -z "${RUNNER_TEMP:-}" ]]; then
    RUNNER_TEMP="$(mktemp -d)"
    trap "rm -rf $RUNNER_TEMP" EXIT
fi

TMPDIR="$RUNNER_TEMP/merge-oci-archives"
if [[ -e "$TMPDIR" ]]; then
    rm -rf "$TMPDIR"
fi
mkdir -p "$TMPDIR"

# Verify all archives exist
for archive in "${@:2}"; do
    if [[ ! -f "$archive" ]]; then
        echo "Archive $archive not found" >&2
        exit 1
    fi
done

# Merge archives and extract manifests
for archive in "${@:2}"; do
    rm -f "$TMPDIR/index.json" "$TMPDIR/oci-layout"
    tar -xf "$archive" -C "$TMPDIR"
    if [[ ! -f "$TMPDIR/index.json" ]]; then
        echo "index.json not found in $archive" >&2
        exit 1
    fi
    if [[ ! -f "$TMPDIR/oci-layout" ]]; then
        echo "oci-layout not found in $archive" >&2
        exit 1
    fi
    manifest="$(cat "$TMPDIR/index.json")"
    if [[ -z "$manifest" ]]; then
        echo "Failed to extract manifest from $archive" >&2
        exit 1
    fi
    if [[ "$(echo "$manifest" | jq -r '.manifests[].platform.os')" = "null" ]]; then
        echo "Manifest does not contain platform.os" >&2
        exit 1
    fi
    if [[ "$(echo "$manifest" | jq -r '.manifests[].platform.architecture')" = "null" ]]; then
        echo "Manifest does not contain platform.architecture" >&2
        exit 1
    fi
    manifests+=("$manifest")
done

# Combine manifests
echo "${manifests[@]}" | jq -s '(. | add ) + ({manifests: (.[0].manifests + .[1].manifests)})' > "$TMPDIR/index.json"

# Create output archive
output_archive_realpath="$(realpath "$output_archive")"
pushd "$TMPDIR"
tar -cf "$output_archive_realpath" *
popd

# Clean up
rm -rf "$TMPDIR"

echo "Output archive $output_archive created" >&2