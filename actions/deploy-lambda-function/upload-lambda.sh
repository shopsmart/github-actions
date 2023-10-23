#!/usr/bin/env bash

function upload-lambda() {
  set -eo pipefail

  local zip_file="${1:-}"
  [ -n "$zip_file" ] || {
    echo "[ERROR] Zip file is required" >&2
    return 1
  }
  [ -f "$zip_file" ] || {
    echo "[ERROR] Cannot find zip file: $zip_file" >&2
    return 2
  }
  local s3_bucket="${2:-}"
  [ -n "$s3_bucket" ] || {
    echo "[ERROR] S3 bucket is required" >&2
    return 3
  }

  local s3_key="${3:-}"
  [ -n "${s3_key:-}" ] || {
    echo "[ERROR] Defaulting the s3 key to the basename of the file" >&2
    s3_key="$(basename "$zip_file")"
  }

  local s3_path="$s3_bucket/$s3_key"
  # Replace all double slashes with a single slash
  s3_path="${s3_path//\/\//\/}"

  echo "[INFO ] Copying $zip_file to s3://$s3_path" >&2
  aws s3 cp "$zip_file" "s3://$s3_path"

  echo "s3-key=$s3_key" >> "$GITHUB_OUTPUT"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  upload-lambda "${@:-}"
  exit $?
fi
