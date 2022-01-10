#!/usr/bin/env bash

function determine-node-version() {
  set -eo pipefail  

  local node_version="${NODE_VERSION:-}"
  if [ -n "$node_version" ]; then
    echo "[DEBUG] Node version provided via input: $node_version" >&2
  elif [ -f .nvmrc ]; then
    echo "[DEBUG] Found .nvmrc file" >&2
    
    node_version="$(< .nvmrc)"
    # NVM keeps the v in the version file
    node_version="${node_version/v/}"
  elif [ -f .node-version ]; then
    echo "[DEBUG] Found .node-version file" >&2

    node_version="$(< .node-version)"
  fi

  [ -n "$node_version" ] || {
    echo "[ERROR] Could not determine node version" >&2
    return 1
  }

  echo "::set-output name=node-version::$node_version"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  determine-node-version "${@:-}"
  exit $?
fi
