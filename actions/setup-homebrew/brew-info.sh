#!/usr/bin/env bash

function brew-info() {
  set -eo pipefail

  local brewfile="${1:-Brewfile}"
  local install="${2:-true}"

  local should_install=false
  if [ "$install" = true ] && [ -f "$brewfile" ]; then
    should_install=true
  fi
  echo "should-install=${should_install}" >> "$GITHUB_OUTPUT"

  local cache_path=''
  cache_path="$(brew --cache)"
  echo "cache-path=${cache_path}" >> "$GITHUB_OUTPUT"

  local prefix_path=''
  prefix_path="$(brew --prefix)"
  echo "prefix-path=${prefix_path}" >> "$GITHUB_OUTPUT"
  echo "bin-paths=${prefix_path}/bin:${prefix_path}/sbin" >> "$GITHUB_OUTPUT"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  brew-info "${@:-}"
  exit $?
fi
