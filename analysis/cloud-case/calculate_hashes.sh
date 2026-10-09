#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ] || [ ! -d "$1" ]; then
    echo "Usage: $0 <directory>" >&2
    exit 1
fi

target_dir="$1"
script_name=$(basename "$0")
exec_time=$(date "+%Y-%m-%d %H:%M:%S")

echo "=================================================="
echo " Script:      $script_name"
echo " Executed:    $exec_time"
echo " Target Dir:  $target_dir"
echo "=================================================="
echo ""

find "$target_dir" -type f | while IFS= read -r file; do
    md5=$(md5sum "$file" | awk '{print $1}')
    sha256=$(sha256sum "$file" | awk '{print $1}')
    echo "File: $file"
    echo "  MD5:    $md5"
    echo "  SHA256: $sha256"
    echo "--------------------------------------------------"
done
