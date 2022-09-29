#!/usr/bin/env bash

function brew-info() {
  set -eo pipefail

  local brewfile="${1:-Brewfile}"
  local install="${2:-true}"

  local should_install=false
  if [ "$install" = true ] && [ -f "$brewfile" ]; then
    should_install=true
  fi
  echo "::set-output name=should-install::${should_install}"

  local cache_path=''
  cache_path="$(brew --cache)"
  echo "::set-output name=cache-path::${cache_path}"

  local prefix_path=''
  prefix_path="$(brew --prefix)"
  echo "::set-output name=prefix-path::${prefix_path}"
  echo "::set-output name=bin-paths::${prefix_path}/bin:${prefix_path}/sbin"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  brew-info "${@:-}"
  exit $?
fi
