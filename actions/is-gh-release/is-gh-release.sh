#!/usr/bin/env bash

function is-gh-release() {
  local ref="${1:-}"
  local is_release=false
  local is_prerelease=false

  if [ -n "$ref" ]; then
    if gh release view "$ref"; then
      echo "::debug::The $ref ref is a release"
      is_release=true
    else
      echo "::debug::Checking for a prerelease"
      local releases=()
      while IFS='' read -r line; do
        releases+=("$line")
      done < <(gh release list | awk -F'\t' '{print $3}')

      if [[ " ${releases[*]} " =~ .*\ "$ref"\ .* ]]; then
        echo "::debug::The $ref ref is a prerelease"
        is_prerelease=true
      else
        echo "::debug::The $ref ref is not a release"
      fi
    fi
  fi

  echo "is-release=$is_release" >> "$GITHUB_OUTPUT"
  echo "is-prerelease=$is_prerelease" >> "$GITHUB_OUTPUT"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  is-gh-release "${@:-}"
  exit $?
fi
