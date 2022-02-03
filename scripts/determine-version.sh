#!/usr/bin/env bash

function determine-version() {
  set -eo pipefail

  local type="$1"
  local version="${2:-}"
  local version_file="${type}-version"

  if [ -n "$version" ]; then
    echo "[DEBUG] Found $type version from input: $version" >&2
  elif [ -f "$version_file" ]; then
    version="$(< "$version_file")"
    echo "[DEBUG] Found $type version from $version_file file: $version" >&2
  else
    # Exceptions
    case "$type" in
      node )
        # Node could be using .nvmrc
        if [ -f .nvmrc ]; then
          version="$(< .nvmrc)"
          # NVM keeps the v in the version file
          version="${version/v/}"
          echo "[DEBUG] Found $type version from .nvmrc file: $version" >&2
        fi
        ;;
    esac
  fi

  [ -n "$version" ] || {
    echo "[ERROR] Could not determine $type version" >&2
    return 1
  }

  echo "::set-output name=version::$version"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  determine-version "${@:-}"
  exit $?
fi
