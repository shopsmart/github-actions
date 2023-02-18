#!/usr/bin/env bash

function tag-resource() {
  set -eo pipefail

  local resource_arn="${1:-}"
  [ -n "$resource_arn" ] || {
    echo "[ERROR] Resource arn not provided" >&2
    return 1
  }

  [ -n "${TAGS:-}" ] || {
    echo "[INFO ] No tags provided" >&2
    return 0
  }

  # Split up tags in put them in the format desired
  #   Input:  key=value
  #   Output: key=$key,value=$value
  while IFS= read -r tag_var; do
    # Remove blank space around the string
    tag_var="$(echo "${tag_var?}" | xargs)"
    key="${tag_var%=*}"
    val="${tag_var#*=}"

    [ -n "${tag_var?}" ] || continue

    tag="key=$key,value=$val"

    echo "[INFO ] Setting the $key tag on resource: $resource_arn" >&2
    aws ecs tag-resource \
      --resource "$resource_arn" \
      --tags "$tag"
  done <<<"$TAGS"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  tag-resource "${@:-}"
  exit $?
fi
