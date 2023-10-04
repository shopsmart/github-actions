#!/usr/bin/env bash

function tag-assets() {
  set -eo pipefail

  if [ "${XTRACE:-false}" = true ]; then
    echo "[DEBUG] Enabling xtrace" >&2
    set -x
  fi

  local path="${1:-}"
  [ -n "$path" ] || {
    echo "[ERROR] Path to assets to tag not provided" >&2
    return 1
  }

  local base_path="$path"
  if [ -f "$path" ]; then
    echo "[DEBUG] A file was provided" >&2
    base_path="$(dirname "$path")"
  elif [ -d "$path" ]; then
    echo "[DEBUG] A directory was provided" >&2
  else
    echo "[ERROR] A file or directory must be provided" >&2
    return 1
  fi

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

  if [ -n "${S3_BUCKET_PATH:-}" ] && [ "${S3_BUCKET_PATH: -1}" = / ]; then
    S3_BUCKET_PATH="${S3_BUCKET_PATH::-1}"
  fi

  find "$path" -type f | while read -r file; do
    file="${file//"$base_path"\/}"
    [ -z "$S3_BUCKET_PATH" ] || file="$S3_BUCKET_PATH/$file"
    aws s3api put-object-tagging \
      --bucket "$S3_BUCKET" \
      --key "$file" \
      --tagging "$tags"
  done
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  tag-assets "${@:-}"
  exit $?
fi
