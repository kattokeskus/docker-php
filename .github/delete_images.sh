#!/bin/bash
# Deletes the container package versions of a PHP version and variant.
# 8.3-bookworm deletes all 8.3 bookworm images. 8.5.11-trixie deletes 8.5.0 to
# 8.5.11 trixie images but keeps the image tagged 8.5-trixie.

set -euo pipefail

SCRIPT_DIR="$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null
cd "$SCRIPT_DIR/.."

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <php-version>-<variant>" >&2
    exit 1
fi
if [[ ! "$1" =~ ^([0-9]+\.[0-9]+)(\.([0-9]+))?-([a-z]+)$ ]]; then
    echo "Invalid version: $1" >&2
    exit 1
fi
target="$(jq -cn --arg minor "${BASH_REMATCH[1]}" --arg patch "${BASH_REMATCH[3]}" --arg variant "${BASH_REMATCH[4]}" \
    '{minor: $minor, patch: (if $patch == "" then null else $patch | tonumber end), variant: $variant}')"

: "${GITHUB_REPOSITORY:?}" "${GITHUB_ACTOR:?}" "${GH_TOKEN:?}"
DRY_RUN="${DRY_RUN:-1}"
OWNER="${GITHUB_REPOSITORY%%/*}"
MANIFEST_TYPES="application/vnd.oci.image.index.v1+json,application/vnd.oci.image.manifest.v1+json,application/vnd.docker.distribution.manifest.list.v2+json,application/vnd.docker.distribution.manifest.v2+json"
export OWNER MANIFEST_TYPES

fetch_manifest() {
    curl -sf -H "Authorization: Bearer $TOKEN" -H "Accept: $MANIFEST_TYPES" \
        "https://ghcr.io/v2/${OWNER}/${PACKAGE}/manifests/$1"
}

# Reads the PHP version from the annotations of the image, or of the first
# image of an index. Base images: title "PHP Base 8.5-trixie", version "8.5.12".
# Extensions: title "PHP 8.5.12-trixie Extension redis".
probe() {
    local manifest child
    manifest="$(fetch_manifest "$1")" || return 0
    child="$(echo "$manifest" | jq -r '.manifests[0].digest // empty')"
    if [[ -n "$child" ]]; then
        manifest="$(fetch_manifest "$child")" || return 0
    fi
    echo "$manifest" | jq -c --arg digest "$1" '.annotations // {}
        | (.["org.opencontainers.image.title"] // "" | capture("(?<minor>[0-9]+\\.[0-9]+)(\\.(?<patch>[0-9]+))?-(?<variant>[a-z]+)")) as $title
        | (.["org.opencontainers.image.version"] // "" | capture("^[0-9]+\\.[0-9]+\\.(?<patch>[0-9]+)$") // {}) as $version
        | {($digest): {minor: $title.minor, patch: ($title.patch // $version.patch | if . then tonumber else null end), variant: $title.variant}}'
}
export -f fetch_manifest probe

# Sleeps until the rate limit resets if fewer than $1 requests remain
wait_rate_limit() {
    local seconds
    seconds="$(gh api rate_limit --jq ".resources.core | if .remaining < $1 then .reset - now | ceil else 0 end")"
    [[ "$seconds" -gt 0 ]] || return 1
    echo "Rate limit reached, waiting ${seconds}s"
    sleep "$seconds"
}

delete() {
    local output tries=0
    while ! output="$(gh api --method DELETE "$1" 2>&1)"; do
        if [[ "$output" == *"rate limit"* ]]; then
            # Secondary rate limits don't tell when they reset
            wait_rate_limit 1 || sleep 60
        elif [[ "$output" == *"(HTTP 5"* ]] && (( ++tries < 5 )); then
            sleep 10
        else
            echo "$1: $output" >&2
            return 1
        fi
    done
    # GitHub asks for a second between mutating requests
    sleep 1
}

failed=0
matched=0
deleted=0
# GITHUB_TOKEN can't list the organization's packages, so the extension
# packages are named as in php-and-extension.yaml
repo="${GITHUB_REPOSITORY#*/}"
packages="${repo}/php-base ${repo}/php-ext-base ${repo}/php-fpm $(docker buildx bake --print -f docker-bake.hcl extensions \
    | jq -r --arg repo "$repo" '. as $bake | [.group.extensions.targets[]
        | "\($repo)/ext/\($bake.target[.].args.EXTENSION // sub("^php-ext-"; ""))"] | unique | join(" ")')"

for PACKAGE in $packages; do
    export PACKAGE
    TOKEN="$(curl -sf --basic -u "${GITHUB_ACTOR}:${GH_TOKEN}" \
        "https://ghcr.io/token?scope=repository:${OWNER}/${PACKAGE}:pull" | jq -r '.token')"
    export TOKEN
    package_uri="$(jq -rn --arg p "$PACKAGE" '$p | @uri')"
    wait_rate_limit 50 || true

    if ! versions="$(gh api --paginate "/orgs/${OWNER}/packages/container/${package_uri}/versions?per_page=100")"; then
        echo "${PACKAGE}: failed to list versions" >&2
        failed=1
        continue
    fi

    # build-<hash>[-<arch>] versions are grouped by hash, others by digest.
    # Tags give the PHP version: 8.5.12-trixie, 6.3.0-php8.5.12-trixie,
    # php8.5-trixie, 8.4.14-trixie-amd64. Groups without such tags are probed.
    versions="$(echo "$versions" \
        | jq -s 'add | map(.metadata.container.tags as $tags | {
            id,
            digest: .name,
            arch: any($tags[]; test("-(amd64|arm64)$")),
            key: ([$tags[] | capture("^build-(?<h>[0-9a-f]+)(-(amd64|arm64))?$").h][0] // .name),
            classes: [$tags[] | capture("(^|php)(?<minor>[0-9]+\\.[0-9]+)(\\.(?<patch>[0-9]+))?-(?<variant>[a-z]+)(-(amd64|arm64))?$")
                | {minor, patch: (.patch | if . then tonumber else null end), variant}]
        })')"
    groups="$(echo "$versions" | jq 'group_by(.key) | map({
        key: .[0].key,
        value: {
            classes: (map(.classes[]) | unique),
            probe: ((map(select(.arch)) + .)[0].digest)
        }
    }) | from_entries')"
    probes="$(echo "$groups" | jq -r '.[] | select(.classes == []) | .probe' \
        | xargs -r -P 8 -n 1 bash -c 'probe "$1"' _ | jq -s 'add // {}')"

    # Versions are deleted only if all their tags match. A minor tag such as
    # 8.5-trixie only matches a target without a patch version.
    result="$(echo "$versions" | jq \
        --slurpfile groups <(echo "$groups") \
        --slurpfile probes <(echo "$probes") \
        --argjson target "$target" '
        def matches: .variant == $target.variant and .minor == $target.minor
            and ($target.patch == null or (.patch != null and .patch <= $target.patch));
        map($groups[0][.key] as $g
            | (if $g.classes == [] then [$probes[0][$g.probe] // empty] else $g.classes end) as $c
            | {
                id,
                patch: ($c | map(.patch) | max),
                label: ($c | map("\(.minor)\(if .patch then ".\(.patch)" else "" end)-\(.variant)") | join(" ")),
                delete: ($c != [] and all($c[]; matches))
            })')"

    delete_ids="$(echo "$result" | jq -r '.[] | select(.delete) | .id')"
    matched=$((matched + $(echo "$result" | jq 'map(select(.delete)) | length')))
    echo "$result" | jq -r --arg package "$PACKAGE" 'map(select(.delete)) as $d
        | "\($package): \($d | length)/\(length) versions to delete"
        + if $d == [] then "" else " (\($d | group_by([.patch, .label]) | map("\(.[0].label): \(length)") | join(", ")))" end'

    if [[ "$DRY_RUN" == "1" ]]; then
        continue
    fi
    for id in $delete_ids; do
        if delete "/orgs/${OWNER}/packages/container/${package_uri}/versions/${id}"; then
            deleted=$((deleted + 1))
        else
            failed=1
        fi
    done
done

echo "${matched} versions matched, ${deleted} deleted"
exit $failed
