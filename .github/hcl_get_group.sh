#!/bin/bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <file> <group>" >&2
    exit 1
fi

file="$1"
group="$2"
if [[ ! -f "$file" ]]; then
    echo "Invalid file: $file not found" >&2
    exit 1
fi

contents="$(cat "$file")"
# Split into lines
contents="$(echo "$contents" | sed -e 's#[{\[]#\0\n#g' -e 's#}\|]#\n\0\n#g')"

group_found=0
targets_found=0
pattern_group="^\s*group\s+\"${group}\"\s+\{\$"
pattern_targets="^\s*targets\s*=\s*\[$"
pattern_end_group="^\s*\}\s*\$"
pattern_end_targets="^\s*\]\s*\$"
pattern_comment="^\s*//"
pattern_empty_line="^\s*$"
targets=()
while IFS= read -r line; do
    if [[ "$line" =~ $pattern_comment ]] || [[ "$line" =~ $pattern_empty_line ]]; then
        continue
    fi
    if [[ $targets_found -eq 1 ]]; then
        if [[ "$line" =~ $pattern_end_targets ]]; then
            for target in "${targets[@]}"; do
                echo "$target"
            done
            exit 0
        fi
        IFS=',' read -ra target < <(echo "$line" | tr -d '" \t')
        targets+=("${target[@]}")
    fi
    if [[ $group_found -eq 1 ]]; then
        if [[ "$line" =~ $pattern_end_group ]]; then
            break
        fi
        if [[ "$line" =~ $pattern_targets ]]; then
            targets_found=1
        fi
        continue
    fi
    if [[ "$line" =~ $pattern_group ]]; then
        group_found=1
    fi
done <<< "$contents"

if [[ $group_found -eq 0 ]]; then
    echo "Failed to find group ${group}" >&2
elif [[ $targets_found -eq 0 ]]; then
    echo "Failed to find targets for group ${group}" >&2
else
    echo "Failed to find end of group ${group}" >&2
fi

exit 1
