#!/usr/bin/env bash
set -euo pipefail
kind=$1
source_dir=$2
version=$3
output_dir=$4
[[ "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]
shopt -s nullglob
case "$kind" in
  rpi) files=("$source_dir"/*.img "$source_dir"/*.img.zst "$source_dir"/*.img.gz); prefix=aperture-bootstrap ;;
  linux) files=("$source_dir"/*.iso "$source_dir"/*.iso.zst "$source_dir"/*.iso.gz); prefix=linux-bootstrap ;;
  *) echo 'Unknown installer kind' >&2; exit 1 ;;
esac
if (( ${#files[@]} == 0 )); then
  echo "No $kind installer images found" >&2
  exit 1
fi
mkdir -p "$output_dir"
for file in "${files[@]}"; do
  test -s "$file"
  cp -L "$file" "$output_dir/$prefix-$version-$(basename "$file")"
done
