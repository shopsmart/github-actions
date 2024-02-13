#!/usr/bin/env bash

function set-output() {
  [ -f "$OUTPUT" ] || touch "$OUTPUT"

  echo "file=$OUTPUT" >> "$GITHUB_OUTPUT"

  # @see https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#multiline-strings
  EOF=$(dd if=/dev/urandom bs=15 count=1 status=none | base64)
  {
    echo "content<<$EOF"
    cat "$OUTPUT"
    echo "$EOF"
  } >> "$GITHUB_OUTPUT"

  rm -rf "$TEMP_DIRECTORY"
}

function render() {
  set -eo pipefail

  # Validation

  [ -n "$TEMPLATE" ] || {
    echo "[ERROR] Template is required" >&2
    return 1
  }

  if ! [ -f "$TEMPLATE" ]; then
    echo "[ERROR] Template file not found: $TEMPLATE" >&2
    return 2
  fi

  [ -z "$UNDEFINED" ] || [ "$UNDEFINED" = true ] || [ "$UNDEFINED" = false ] || {
    echo "[ERROR] Undefined must be 'true' or 'false' but received $UNDEFINED" >&2
    return 3
  }

  TEMP_DIRECTORY="$(mktemp -d)"
  export TEMP_DIRECTORY

  if [ -n "$DATA" ]; then
    local ext=''
    local data_files=()
    while read -r file; do
      [ -n "$file" ] || continue
      [ -n "$ext"  ] || ext="${file##*.}"
      [ -f "$file" ] || {
        echo "[ERROR] Data file not found: $file" >&2
        return 2
      }
      data_files+=("$file")
    done <<< "$DATA"

    if [ ${#data_files[@]} -gt 1 ]; then
      DATA="$TEMP_DIRECTORY/data.$ext"
      echo "[DEBUG] Merging ${data_files[*]} to $DATA" >&2
      confmerge "${data_files[@]}" "$DATA"
    fi
  fi

  # Main
  trap set-output EXIT

  echo "[DEBUG] $(jinjanate --version)" >&2
  echo "[DEBUG] $(confmerge --version)" >&2

  local COMMAND=(jinjanate --quiet --output-file "$OUTPUT")

  [ "$UNDEFINED" != "true" ] || COMMAND+=(--undefined)

  [ -z "$FORMAT" ] || COMMAND+=(--format "$FORMAT")

  [ -z "$FORMAT_OPTIONS" ] || {
    while IFS= read -r option; do
      COMMAND+=(--format-option "$option")
    done <<<"$FORMAT_OPTIONS"
  }

  [ -z "$ENV_VARS" ] || {
    while IFS= read -r env_var; do
      # Remove blank space around the string
      env_var="$(echo "${env_var?}" | xargs)"
      var="${env_var%=*}"

      [ -n "${env_var?}" ] || continue

      # Export for the j2 cli
      export "${env_var?}"

      COMMAND+=(--import-env "$var")
    done <<<"$ENV_VARS"
  }

  COMMAND+=("$TEMPLATE")
  [ -z "$DATA" ] || COMMAND+=("$DATA")

  echo "[DEBUG] ${COMMAND[*]}" >&2
  "${COMMAND[@]}"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  render
  exit $?
fi
