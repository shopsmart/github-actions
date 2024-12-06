#!/usr/bin/env bash

function update-alias() {
  set -eo pipefail

  local function_name="${1:-}"
  [ -n "$function_name" ] || {
    echo "[ERROR] Function name not provided" >&2
    return 1
  }

  local alias_name="${2:-}"
  [ -n "$alias_name" ] || {
    echo "[ERROR] Alias name not provided" >&2
    return 2
  }

  local version="${3:-}"
  [ -n "$version" ] || {
    echo "[ERROR] Version not provided" >&2
    return 2
  }

  aws lambda update-alias \
    --function-name "$function_name" \
    --name "$alias_name" \
    --function-version "$version" \
    --no-cli-pager
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  update-alias "${@:-}"
  exit $?
fi
