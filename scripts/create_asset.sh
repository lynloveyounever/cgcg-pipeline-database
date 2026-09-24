#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <show-root> <characters|props|environments|fx> <asset_name>" >&2
  exit 2
}

[[ $# -eq 3 ]] || usage

show_root=${1%/}
asset_type=$2
asset_name=$3

case "$asset_type" in
  characters|props|environments|fx) ;;
  *) echo "Error: unsupported asset type: $asset_type" >&2; usage ;;
esac

if [[ ! "$asset_name" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "Error: asset_name must match [a-z][a-z0-9_]*" >&2
  exit 2
fi

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
template_dir=$(cd -- "$script_dir/../templates/asset" && pwd)
destination="$show_root/assets/$asset_type/$asset_name"

if [[ -e "$destination" ]]; then
  echo "Error: destination already exists: $destination" >&2
  exit 1
fi

mkdir -p "$destination"
cp -R "$template_dir/." "$destination/"

for task in design model surfacing rig groom lookdev; do
  mkdir -p "$destination/$task/work" "$destination/$task/publish"
done
mkdir -p "$destination/reference" "$destination/cache/incoming" "$destination/cache/publish"

# Keep the empty standard directories when the tree itself is stored in Git.
find "$destination" -type d -empty -exec touch '{}/.gitkeep' \;

echo "Created asset: $destination"
