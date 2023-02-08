#!/usr/bin/env bash

function copy-workflow() {
  set -eo pipefail

  [ $# -gt 0 ] || {
    echo "Usage: copy-workflow WORKFLOW_FILE" >&2
    return 1
  }

  local workflow_file="$1"
  local workflow_name=''
  workflow_name="$(basename "$workflow_file" .yml)"

  cp "$workflow_file" ".github/workflows/$workflow_name.yml"
  git add ".github/workflows/$workflow_name.yml"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  copy-workflow "${@:-}"
  exit $?
fi
