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

  echo "[INFO ] Pulling source image '$source'..." >&2
  docker pull "$source" || {
    echo "[ERROR] Source image '$source' does not exist or cannot be pulled." >&2
    return 1
  }

  local status=$?

  local retagged_images=()
  for target in "${targets[@]}"; do
    [ -n "$target" ] || continue

    echo "[INFO ] Retagging $source to $target..." >&2
    docker tag "$source" "$target"

    echo "[INFO ] Pushing $target..." >&2
    docker push "$target" || {
      echo "[ERROR] Failed to push $target." >&2
      status=2
      continue
    }
    retagged_images+=("$target")
  done

  echo "tags=${retagged_images[*]}" >> "$GITHUB_OUTPUT"
  return $status
}

if [ "$0" = "${BASH_SOURCE[0]}" ]; then
  set -eo pipefail
  retag-docker-image "${@:-}"
  exit $?
fi
