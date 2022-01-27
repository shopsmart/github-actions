#!/usr/bin/env bash

function upload-static-assets() {
  set -eo pipefail

  local path="$1"

  local s3_path="$S3_BUCKET"
  [ -z "${S3_BUCKET_PATH:-}" ] || s3_path+="/$S3_BUCKET_PATH"

  echo "[DEBUG] Copying $path/ to s3://$s3_path/" >&2
  aws s3 cp --recursive "$path/" "s3://$s3_path/"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  upload-static-assets "${@:-}"
  exit $?
fi
