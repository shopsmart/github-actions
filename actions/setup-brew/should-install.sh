#!/usr/bin/env bash

function should-install() {
  set -eo pipefail

  local brewfile="${1:-Brewfile}"
  local install="${2:-true}"

  local answer=false
  if [ "$install" = true ] && [ -f "$brewfile" ]; then
    answer=true
  fi

  echo "::set-output name=answer::${answer}"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  should-install "${@:-}"
  exit $?
fi
