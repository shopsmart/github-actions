#!/usr/bin/env bats

load version-lambda.sh

function setup() {
  export AWS_CMD_FILE="$BATS_TEST_TMPDIR/aws.cmd"
  export -f aws

  export LAMBDA_FUNCTION=fake-function

  export GITHUB_OUTPUT="$BATS_TEST_TMPDIR/output.txt"
}

function teardown() {
  rm -f "$AWS_CMD_FILE"
}

function aws() {
  echo "$*" >> "$AWS_CMD_FILE"
  echo "1"
}

@test "it should require a function name" {
  run version-lambda

  [ "$status" -ne 0 ]
}

@test "it should require a version" {
  run version-lambda "$LAMBDA_FUNCTION"

  [ "$status" -ne 0 ]
}

@test "it should publish a version of the lambda" {
  run version-lambda "$LAMBDA_FUNCTION" v1.0.0

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  cat "$AWS_CMD_FILE" >&3
  [ "$(< "$AWS_CMD_FILE")" = "lambda publish-version --function-name $LAMBDA_FUNCTION --description v1.0.0 --query .Version --output text --no-cli-pager" ]
}

@test "it should pass the revision id if provided" {
  export REVISION_ID=123456

  run version-lambda "$LAMBDA_FUNCTION" v1.0.0

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [ "$(< "$AWS_CMD_FILE")" = "lambda publish-version --function-name $LAMBDA_FUNCTION --description v1.0.0 --revision-id $REVISION_ID --query .Version --output text --no-cli-pager" ]
}

@test "it should output the version number" {
  run version-lambda "$LAMBDA_FUNCTION" v1.0.0

  [ "$status" -eq 0 ]
  [ -f "$GITHUB_OUTPUT" ]
  cat "$GITHUB_OUTPUT"
  [ "$(< "$GITHUB_OUTPUT")" = version=1 ]
}
