#!/usr/bin/env bash

function use-local-actions() {
  set -eo pipefail

  for file in actions/*/action.yml; do
    sed -i.bak \
      's/uses: shopsmart\/github-actions\/actions\/\(.*\)@.*/uses: .\/actions\/\1/p' \
      "$file"
  done
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  use-local-actions "${@:-}"
  exit $?
fi
