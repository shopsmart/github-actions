#!/usr/bin/env bats

load render.sh

function jinjanate() {
  echo "$*" >> "$J2_CMD_FILE"
  env >> "$J2_ENV_FILE"
}

function confmerge() {
  echo "$*" >> "$CONFMERGE_CMD_FILE"
}

function mktemp() {
  mkdir -p "$TEST_TEMP_DIRECTORY"
  echo "$TEST_TEMP_DIRECTORY"
}

function setup() {
  export J2_CMD_FILE="$BATS_TEST_TMPDIR/j2.cmd"
  export J2_ENV_FILE="$BATS_TEST_TMPDIR/j2.env"

  export CONFMERGE_CMD_FILE="$BATS_TEST_TMPDIR/confmerge.cmd"

  export TEST_TEMP_DIRECTORY="$BATS_TEST_TMPDIR/tmp"

  # Use mock j2 and confmerge commands
  export -f \
    jinjanate \
    confmerge \
    mktemp

  # Template is required (per action.yml)
  TEMPLATE="$BATS_TEST_TMPDIR/template.j2"
  touch "$TEMPLATE"
  export TEMPLATE

  # Output has a default (per action.yml)
  OUTPUT="$BATS_TEST_TMPDIR/output.yml"
  touch "$OUTPUT"
  export OUTPUT

  GITHUB_OUTPUT="$BATS_TEST_TMPDIR/github.output"
  touch "$GITHUB_OUTPUT"
  export GITHUB_OUTPUT

  # Undefined defaults to false (per action.yml), but empty also works
}

function teardown() {
  :
}

@test "it should error out if template is empty" {
  unset TEMPLATE

  run render

  [ $status -eq 1 ]
}

@test "it should error out if template is not a file" {
  rm -f "$TEMPLATE"

  run render

  [ $status -eq 2 ]
}

@test "it should error out if data is not a file" {
  export DATA="$BATS_TEST_TMPDIR/data.yml"

  run render

  [ $status -eq 2 ]
}

@test "it should error out if undefined is not a boolean" {
  export UNDEFINED="notaboolean"

  run render

  [ $status -eq 3 ]
}

@test "it should not pass the undefined flag if undefined is false" {
  export UNDEFINED="false"

  run render

  [ $status -eq 0 ]
  [ -f "$J2_CMD_FILE" ]
  grep -vq -- '--undefined' "$J2_CMD_FILE"
}

@test "it should export environment variables to the cli" {
  export ENV_VARS='FOO=bar
  BAR=baz
  BAZ=quo'

  run render

  [ $status -eq 0 ]
  [ -f "$J2_CMD_FILE" ] && [ -f "$J2_ENV_FILE" ]
  grep -q -- '--import-env FOO' "$J2_CMD_FILE"
  grep -q 'FOO=bar' "$J2_ENV_FILE"
  grep -q -- '--import-env BAR' "$J2_CMD_FILE"
  grep -q 'BAR=baz' "$J2_ENV_FILE"
  grep -q -- '--import-env BAZ' "$J2_CMD_FILE"
  grep -q 'BAZ=quo' "$J2_ENV_FILE"
}

@test "it should pass all arguments to the j2 cli" {
  export DATA="$BATS_TEST_TMPDIR/data.yml"

  touch "$DATA"

  export UNDEFINED=true
  export ENV_VARS='FOO=foo
BAR=bar
  '
  export FORMAT='my-custom-format'
  export FORMAT_OPTIONS='option1=foo
option2=bar
  '

  run render

  [ $status -eq 0 ]
  grep -q -- "--import-env FOO" "$J2_CMD_FILE"
  grep -q -- "--import-env BAR" "$J2_CMD_FILE"
  grep -q -- "--undefined" "$J2_CMD_FILE"
  grep -q -- "--format my-custom-format" "$J2_CMD_FILE"
  grep -q -- "--format-option option1=foo" "$J2_CMD_FILE"
  grep -q -- "--format-option option2=bar" "$J2_CMD_FILE"
  grep -qE "$TEMPLATE $DATA\$" "$J2_CMD_FILE"
}

@test "it should not call confmerge when there is a single data file" {
  export DATA="$BATS_TEST_TMPDIR/data.yml"

  touch "$DATA"

  run render

  [ "$status" -eq 0 ]
  [ -f "$CONFMERGE_CMD_FILE" ] # --version is called on it
  [ "$(< "$CONFMERGE_CMD_FILE")" = "--version" ]
}

@test "it should merge files when multiple data files are provided" {
  DATA_FILE_1="$BATS_TEST_TMPDIR/data.yml"
  DATA_FILE_2="$BATS_TEST_TMPDIR/secondary.yml"

  export DATA="$DATA_FILE_1
$DATA_FILE_2"

  touch "$DATA_FILE_1"
  touch "$DATA_FILE_2"

  run render

  grep -qE "$DATA_FILE_1 $DATA_FILE_2 $TEST_TEMP_DIRECTORY/data.yml\$" "$CONFMERGE_CMD_FILE"
  grep -qE "$TEMPLATE $TEST_TEMP_DIRECTORY/data.yml\$" "$J2_CMD_FILE"
}
