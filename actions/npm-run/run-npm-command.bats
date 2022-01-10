#!/usr/bin/env bats

load run-npm-command.sh

function setup() {
  export NPM_CMD_FILE="$BATS_TEST_TMPDIR/npm.cmd"
  export -f npm
}

function teardown() {
  rm -f "$NPM_CMD_FILE"

  unset NPM_STATUS
}

function npm() {
  echo "$*" > "$NPM_CMD_FILE"
  echo "Stdout
over
multiple
lines"
  echo "Stderr
over
multiple
lines" >&2

  return "${NPM_STATUS:-0}"
}

@test "it should output stdout and stderr to outputs" {
  run run-npm-command

  [ "$status" -eq 0 ]
  [[ "$output" =~ .*::set-output\ name=stdout::Stdout'%0A'over'%0A'multiple'%0A'lines.* ]]
  [[ "$output" =~ .*::set-output\ name=stderr::Stderr'%0A'over'%0A'multiple'%0A'lines.* ]]
}

@test "it should error out if the npm command was unsuccessful" {
  export NPM_STATUS=255

  run run-npm-command

  [ $status -eq 255 ]
}
