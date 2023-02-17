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
  local tags=''
  while IFS= read -r tag_var; do
    # Remove blank space around the string
    tag_var="$(echo "${tag_var?}" | xargs)"
    key="${tag_var%=*}"
    val="${tag_var#*=}"

    [ -n "${tag_var?}" ] || continue

    tags+="{key='""$key""',value='""$val""'},"
  done <<<"$TAGS"
  tags="[${tags::-1}]" # pop off the last comma

  aws ecs tag-resource \
    --resource "$resource_arn" \
    --tags "$tags"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  tag-resource "${@:-}"
  exit $?
fi
