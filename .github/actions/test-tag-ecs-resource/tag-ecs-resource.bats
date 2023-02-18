#!/usr/bin/env bats

function setup() {
  :
}

function teardown() {
  :
}

@test "it should have tagged the version" {
  run aws ecs describe-task-definition \
    --task-definition "$RESOURCE_ARN" \
    --no-cli-pager \
    --output text \
    --include TAGS \
    --query 'tags[?key==`version`].value'

  [ "$status" -eq 0 ]
  [ "$output" = "$VERSION" ]
}
