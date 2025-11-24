#!/bin/bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <file> <variable>" >&2
    exit 1
fi

file="$1"
variable="$2"
if [[ ! -f "$file" ]]; then
    echo "Invalid file: $file not found" >&2
    exit 1
fi

contents="$(cat "$file")"
# Split into lines
contents="$(echo "$contents" | sed -e 's#[{\[]#\0\n#g' -e 's#}\|]#\n\0\n#g')"

var_found=0
pattern_variable="^\s*variable\s+\"${variable}\"\s+\{\$"
pattern_default="^\s*default\s*=\s*"
pattern_default_string="^\s*default\s*=\s*\"([^\"]+)\"\s*\$"
while IFS= read -r line; do
    if [[ "$line" =~ ^\s*# ]] || [[ "$line" =~ ^\s*$ ]]; then
        continue
    fi
    if [[ $var_found -eq 1 ]]; then
        if [[ "$line" =~ $pattern_default ]]; then
            if [[ "$line" =~ $pattern_default_string ]]; then
                echo "${BASH_REMATCH[1]}"
                exit 0
            else
                echo "default value is not a string" >&2
                exit 1
            fi
            break
        fi
        continue
    fi
    if [[ "$line" =~ $pattern_variable ]]; then
        var_found=1
    fi
done <<< "$contents"

if [[ $var_found -eq 0 ]]; then
    echo "Failed to find variable ${variable}" >&2
else
    echo "Failed to find default value for variable ${variable}" >&2
fi

exit 1