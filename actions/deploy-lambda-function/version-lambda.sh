#!/usr/bin/env bash

function version-lambda() {
  set -eo pipefail

  local function_name="${1:-}"
  [ -n "$function_name" ] || {
    echo "[ERROR] Function name not provided" >&2
    return 1
  }

  local description="${2:-}"
  [ -n "$description" ] || {
    echo "[ERROR] Version not provided" >&2
    return 2
  }

  local revision_id="${REVISION_ID:-}"
  [ -z "$revision_id" ] || options+=(--revision-id "$revision_id")

  local version=''
  # shellcheck disable=SC2068
  # We want options to expand here
  version="$(
    aws lambda publish-version \
      --function-name "$function_name" \
      --description "$description" \
      ${options[@]} \
      --query Version \
      --output text \
      --no-cli-pager
  )"
  echo "version=$version" >> "$GITHUB_OUTPUT"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  version-lambda "${@:-}"
  exit $?
fi
