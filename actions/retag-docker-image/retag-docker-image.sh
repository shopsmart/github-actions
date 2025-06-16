#!/usr/bin/env bash

function retag-docker-image() {
  local source="$1"
  shift || :

  local targets=("$@")
  if [ ${#targets[@]} -eq 0 ]; then
    # Read targets from the TARGETS environment variable if no arguments are provided
    while read -r target; do
      [ -n "$target" ] || continue
      targets+=("$target")
    done <<< "${TARGETS:-}"
  fi

  if [ -z "$source" ]; then
    echo "Usage: $0 <source-image> [<target-image1> <target-image2> ...]"
    return 1
  fi

  if [ ${#targets[@]} -eq 0 ]; then
    echo "[INFO ] No target images specified." >&2
    return 0
  fi

  local retagged_images=()
  for target in "${targets[@]}"; do
    [ -n "$target" ] || continue

    echo "[INFO ] Retagging $source to $target..." >&2
    docker tag "$source" "$target"
    retagged_images+=("$target")
  done

  echo "tags=${retagged_images[*]}" >> "$GITHUB_OUTPUT"
}

if [ "$0" = "${BASH_SOURCE[0]}" ]; then
  set -eo pipefail
  retag-docker-image "${@:-}"
  exit $?
fi
