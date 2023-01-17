#!/usr/bin/env bash

function is-gh-release() {
  local ref="${1:-}"
  local is_release=false

  if [ -n "$ref" ]; then
    if gh release view "$ref"; then
      echo "::debug::The $ref ref is a release"
      is_release=true
    else
      echo "::debug::The $ref ref is not a release"
    fi
  fi

  echo "is-release=$is_release" >> "$GITHUB_OUTPUT"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  is-gh-release "${@:-}"
  exit $?
fi
