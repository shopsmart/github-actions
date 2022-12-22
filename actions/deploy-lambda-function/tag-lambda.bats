#!/usr/bin/env bats

load tag-lambda.sh

function setup() {
  export AWS_CMD_FILE="$BATS_TEST_TMPDIR/aws.cmd"
  export -f aws

  export LAMBDA_FUNCTION=fake-function
  export LAMBDA_TAGS='foo=bar
enabled=true
key=value'
  export LAMBDA_ARN='arn:aws:us-east-1:1234567890:function/fake-function'
}

function teardown() {
  rm -f "$AWS_CMD_FILE"
}

function aws() {
  echo "$*" >> "$AWS_CMD_FILE"
  if [ "$2" = "get-function" ]; then
    echo "$LAMBDA_ARN"
  fi
}

@test "it should error if no function name was provided" {
  run tag-lambda

  [ "$status" -ne 0 ]
}

@test "it should return early if no tags are provided" {
  unset LAMBDA_TAGS

  run tag-lambda "$LAMBDA_FUNCTION"

  [ "$status" -eq 0 ]
  ! [ -f "$AWS_CMD_FILE" ]
}

@test "it should find the function arn when tags are provided" {
  run tag-lambda "$LAMBDA_FUNCTION"

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [[ "$(< "$AWS_CMD_FILE")" =~ .*"lambda get-function --function-name $LAMBDA_FUNCTION".* ]]
}

@test "it should tag the lambda" {
  run tag-lambda "$LAMBDA_FUNCTION"

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [[ "$(< "$AWS_CMD_FILE")" =~ .*"lambda tag-resource --resource $LAMBDA_ARN --tags ${LAMBDA_TAGS//$'\n'/,}".* ]]
}
