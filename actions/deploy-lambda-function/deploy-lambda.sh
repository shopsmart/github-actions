#!/usr/bin/env bash

function deploy-lambda() {
  set -eo pipefail

  local function_name="$1"
  local zip_file="${2:-}"
  local s3_bucket="${S3_BUCKET:-}"
  local s3_key="${S3_KEY:-}"
  local s3_object_version="${S3_OBJECT_VERSION:-}"

  # validate
  [ -n "$function_name" ] || {
    echo "[ERROR] A function name must be provided" >&2
    return 1
  }
  if [ -z "$zip_file" ]; then
    if [ -z "$s3_bucket" ] || [ -z "$s3_key" ]; then
      echo "[ERROR] A zip file or an s3 bucket and s3 key must be provided" >&2
      return 2
    fi
  fi

  local options=()

  if [ -z "$s3_bucket" ] || [ -z "$s3_key" ]; then
    # resolve zip file if wildcard
    [ "$zip_file" = "${zip_file#*\*}" ] || {
      echo "[DEBUG] Found a wildcard file" >&2
      local pre_wildcard="${zip_file%\**}"
      local post_wildcard="${zip_file#*\*}"
      zip_file="$(builtin echo "$pre_wildcard"*"$post_wildcard")"
      echo "[DEBUG] Expanded '$pre_wildcard*$post_wildcard' to $zip_file" >&2
    }
    [ -f "$zip_file" ] || {
      echo "[ERROR] Zip file does not exist" >&2
      return 3
    }

    echo "[DEBUG] Uploading $zip_file to $function_name function" >&2
    options+=(--zip-file "fileb://$zip_file")
  else
    options+=(--s3-bucket "$s3_bucket")
    options+=(--s3-key "$s3_key")
    # object version
    [ -z "$s3_object_version" ] || options+=(--s3-object-version "$s3_object_version")

    echo "[DEBUG] Updating $function_name function to use s3://$s3_bucket/$s3_key#$s3_object_version" >&2
  fi

  # shellcheck disable=SC2068
  # We want options to expand here
  aws lambda update-function-code --function-name "$function_name" ${options[@]}
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  deploy-lambda "${@:-}"
  exit $?
fi
