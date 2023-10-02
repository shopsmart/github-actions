#!/usr/bin/env bash

function upload-assets() {
  set -eo pipefail

  local path="$1"

  local s3_path="$S3_BUCKET"
  if [ -n "${S3_BUCKET_PATH:-}" ] && [ "${s3_path:0:1}" != / ]; then
    s3_path+="/$S3_BUCKET_PATH"
  fi

  local options=()

  if [ -d "$path" ]; then
    echo "[DEBUG] $path is a directory" >&2

    [ "${path: -1}" = /    ] || path="$path/"
    [ "${s3_path: -1}" = / ] || s3_path="$s3_path/"

    options+=(--recursive)
  elif [ -f "$path" ]; then
    echo "[DEBUG] $path is a file" >&2
    [ -n "${S3_BUCKET_PATH:-}" ] || s3_path="$s3_path/"
  else
    echo "[ERROR] Could not find a file or directory for $path" >&2
    return 1
  fi

  echo "[DEBUG] Copying $path to s3://$s3_path" >&2
  # shellcheck disable=SC2068
  # We want the options to expand
  aws s3 cp ${options[@]} "$path" "s3://$s3_path"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  upload-assets "${@:-}"
  exit $?
fi
