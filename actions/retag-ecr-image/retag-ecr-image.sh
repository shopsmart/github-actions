#!/usr/bin/env bash

function retag-ecr-image() {
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

  # format: <registry>/<repository>:<tag>
  if [[ ! "$source" =~ ^([a-zA-Z0-9._-]+/)?[a-zA-Z0-9._-]+:[a-zA-Z0-9._-]+$ ]]; then
    echo "[ERROR] Invalid source image format: '$source'. Expected format: <registry>/<repository>:<tag>" >&2
    return 1
  fi

  if [ ${#targets[@]} -eq 0 ]; then
    echo "[INFO ] No target images specified." >&2
    return 0
  fi

  local source_repo_name="${source%%:*}"      # pull everything before the colon
  source_repo_name="${source_repo_name##*/}"  # remove everything before the last slash
  local source_repo_tag="${source##*:}"       # pull everything after the colon

  echo "[INFO ] Pulling manifest for source image '$source_repo_name'..." >&2
  local manifest=''
  # @see https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-retag.html
  manifest="$(
    aws ecr batch-get-image \
      --repository-name "$source_repo_name" \
      --image-ids imageTag="$source_repo_tag" \
      --output text \
      --query 'images[].imageManifest'
  )"

  local status=$?
  if [ $status -ne 0 ]; then
    echo "[ERROR] Source image '$source' does not exist or cannot be pulled." >&2
    return $status
  fi

  local retagged_images=()
  for target in "${targets[@]}"; do
    [ -n "$target" ] || continue

    # format: <registry>/<repository>:<tag>
    if [[ ! "$target" =~ ^([a-zA-Z0-9._-]+/)?[a-zA-Z0-9._-]+:[a-zA-Z0-9._-]+$ ]]; then
      echo "[ERROR] Invalid target image format: '$target'. Expected format: <registry>/<repository>:<tag>" >&2
      status=2
      continue
    fi

    local target_repo_name="${target%%:*}"      # pull everything before the colon
    target_repo_name="${target_repo_name##*/}"  # remove everything before the last slash
    local target_repo_tag="${target##*:}"       # pull everything after the colon

    echo "[INFO ] Retagging $source to $target..." >&2
    aws ecr put-image \
      --repository-name "$target_repo_name" \
      --image-tag "$target_repo_tag" \
      --image-manifest "$manifest" || \
    {
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
  retag-ecr-image "${@:-}"
  exit $?
fi
