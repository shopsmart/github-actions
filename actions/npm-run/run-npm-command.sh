#!/usr/bin/env bash

function run-npm-command() {
  local args=("$@")
  local status=0
  local stdout=''
  local stderr=''

  local tmpdir=''
  tmpdir="$(mktemp -d)"
  # shellcheck disable=SC2064
  # https://github.com/koalaman/shellcheck/wiki/SC2064
  # We want this variable to expand now
  trap "rm -rf $tmpdir" EXIT

  local stdout_file="$tmpdir/stdout"
  local stderr_file="$tmpdir/stderr"

  echo "[DEBUG] Running npm command: ${args[*]}" >&2
  npm run "${args[@]}" >"$stdout_file" 2>"$stderr_file"
  status="$?"

  stdout="$(< "$stdout_file")"
  stderr="$(< "$stderr_file")"

  # Multiline outputs need special treatment
  # @see https://trstringer.com/github-actions-multiline-strings/
  stdout="${stdout//'%'/'%25'}"
  stdout="${stdout//$'\n'/'%0A'}"
  stdout="${stdout//$'\r'/'%0D'}"

  stderr="${stderr//'%'/'%25'}"
  stderr="${stderr//$'\n'/'%0A'}"
  stderr="${stderr//$'\r'/'%0D'}"

  # Outputs
  echo "::set-output name=stdout::$stdout"
  echo "::set-output name=stderr::$stderr"

  # Return status from npm command
  echo "[DEBUG] Status of npm command: $status" >&2
  return "$status"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  run-npm-command "${@:-}"
  exit $?
fi
