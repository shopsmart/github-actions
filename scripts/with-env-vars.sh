#!/usr/bin/env bash

function with-env-vars() {
  set -eo pipefail

  local env_vars="${ENV_VARS:-}"

  local key='' val=''

  [ -z "$env_vars" ] || {
    while IFS= read -r env_var; do
      # Remove blank space around the string
      env_var="$(echo "${env_var?}" | xargs)"
      key="${env_var%=*}"
      val="${env_var#*=}"

      # Toss out empty lines
      [ -n "${env_var?}" ] || continue

      echo "[INFO ] Exporting $key as environment variable" >&2
      export "$key"="${val}"
    done <<<"$env_vars"

    echo "[INFO ] Running $*" >&2
    exec "$@"
  }
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  with-env-vars "${@:-}"
  exit $?
fi
