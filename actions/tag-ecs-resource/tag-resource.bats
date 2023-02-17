#!/usr/bin/env bats

load tag-resource.sh

function setup() {
  export AWS_CMD_FILE="$BATS_TEST_TMPDIR/aws.cmd"
  export -f aws

  export RESOURCE_ARN=my-resource-arn
  export TAGS='Foo=bar
team=my-team
owner=anonymous
'
}

function teardown() {
  rm -f "$AWS_CMD_FILE"
}

function aws() {
  echo "$*" >> "$AWS_CMD_FILE"
}

@test "it should error out if no resource arn is provided" {
  run tag-resource

  [ "$status" -ne 0 ]
}

@test "it should tag the resource" {
  run tag-resource "$RESOURCE_ARN"

  tagset="[{key='Foo',value='bar'},{key='team',value='my-team'},{key='owner',value='anonymous'}]"

  cat "$AWS_CMD_FILE"

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [ "$(< "$AWS_CMD_FILE")" = "ecs tag-resource --resource my-resource-arn --tags $tagset" ]
}

@test "it should do nothing with no tags" {
  export TAGS=''

  run tag-resource "$RESOURCE_ARN"

  [ "$status" -eq 0 ]
  ! [ -f "$AWS_CMD_FILE" ]
}
