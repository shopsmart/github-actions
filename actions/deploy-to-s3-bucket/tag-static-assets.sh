#!/usr/bin/env bash

function tag-static-assets() {
  set -eo pipefail

  local path="${1:-}"
  [ -n "$path" ] || {
    echo "[ERROR] Path to assets to tag not provided" >&2
    return 1
  }

  [ -n "$S3_TAGS" ] || {
    echo "[DEBUG] No tags provided" >&2
    return 0
  }

  local tags=''
  while IFS= read -r tag_var; do
    # Remove blank space around the string
    tag_var="$(echo "${tag_var?}" | xargs)"
    key="${tag_var%=*}"
    val="${tag_var#*=}"

    [ -n "${tag_var?}" ] || continue

    tags+="{Key='""$key""',Value='""$val""'},"
  done <<<"$S3_TAGS"
  tags="TagSet=[${tags::-1}]"

  find "$path" -type f | while read -r file; do
    file="${file//"$path"\/}"
    [ -z "$S3_BUCKET_PATH" ] || file="$S3_BUCKET_PATH/$file"
    aws s3api put-object-tagging \
      --bucket "$S3_BUCKET" \
      --key "$file" \
      --tagging "$tags"
  done
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  tag-static-assets "${@:-}"
  exit $?
fi
