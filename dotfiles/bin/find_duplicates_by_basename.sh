#!/bin/bash

# Set the root directory to search (default to current directory if not provided)
ROOT_DIR="${1:-.}"

# Traverse directories
find "$ROOT_DIR" -type f | while read -r file; do
    dir=$(dirname "$file")
    base=$(basename "$file")
    filename="${base%.*}"  # Remove extension
    extension="${base##*.}"

    echo "$dir|$filename|$extension"
done | sort | uniq | awk -F'|' '
{
    key = $1 "|" $2
    map[key] = map[key] "," $3
    count[key]++
}
END {
    for (k in count) {
        if (count[k] >= 2) {
            split(k, parts, "|")
            print "Directory: " parts[1]
            print "Base filename: " parts[2]
            exts = substr(map[k], 2)
            split(exts, ext_list, ",")
            for (i in ext_list) {
                print "  ." ext_list[i]
            }
            print ""
        }
    }
}
'
