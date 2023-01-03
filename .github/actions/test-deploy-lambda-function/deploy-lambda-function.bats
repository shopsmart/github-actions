#!/usr/bin/env bats

function setup() {
  :
}

function teardown() {
  :
}

@test "it should have deployed the code to lambda" {
  # TODO: How do we test this?
  run :

  [ "$status" -eq 0 ]
}

@test "it should have tagged the lambda version" {
  run aws lambda list-tags --no-cli-pager \
    --resource "$FUNCTION_ARN" \
    --query 'Tags.version' \
    --output text

  [ "$status" -eq 0 ]
  [ "$output" = "$VERSION_TAG" ]
}
