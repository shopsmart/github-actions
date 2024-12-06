#!/usr/bin/env bats

load update-alias.sh

function setup() {
  export AWS_CMD_FILE="$BATS_TEST_TMPDIR/aws.cmd"
  export -f aws

  export GITHUB_OUTPUT="$BATS_TEST_TMPDIR/output.txt"
}

function teardown() {
  rm -f "$AWS_CMD_FILE"
}

function aws() {
  echo "$*" > "$AWS_CMD_FILE"
}

@test "it should require the function name" {
  run update-alias

  [ "$status" -ne 0 ]
}

@test "it should require the alias name" {
  run update-alias my-function

  [ "$status" -ne 0 ]
}

@test "it should require the version" {
  run update-alias my-function my-alias

  [ "$status" -ne 0 ]
}

@test "it should update the alias" {
  run update-alias my-function my-alias 1

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [ "$(< "$AWS_CMD_FILE")" = "lambda update-alias --function-name my-function --name my-alias --function-version 1 --no-cli-pager" ]
}
