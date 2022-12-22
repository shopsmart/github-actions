#!/usr/bin/env bash

function deploy-lambda() {
  set -eo pipefail

  local function_name="$1"
  local zip_file="$2"

  [ -n "$function_name" ] || {
    echo "[ERROR] A function name must be provided" >&2
    return 1
  }
  [ -n "$zip_file" ] || {
    echo "[ERROR] A zip file must be provided" >&2
    return 2
  }
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
  aws lambda update-function-code \
    --function-name "$function_name" \
    --zip-file "$zip_file"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  deploy-lambda "${@:-}"
  exit $?
fi
