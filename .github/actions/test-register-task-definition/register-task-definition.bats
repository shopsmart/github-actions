#!/usr/bin/env bats

function setup() {
  export FAMILY_REVISION="${TASK_DEFINITION_ARN#*task-definition/}"
}

function teardown() {
  :
}

@test "it should have updated the task definition" {
  run aws ecs describe-task-definition \
    --task-definition "$FAMILY_REVISION" \
    --no-cli-pager \
    --output text \
    --query 'taskDefinition.containerDefinitions[0].dockerLabels.version'

  [ "$status" -eq 0 ]
  [ "$output" = "$VERSION" ]
}

@test "it should have tagged the task definition" {
  run aws ecs describe-task-definition \
    --task-definition "$FAMILY_REVISION" \
    --no-cli-pager \
    --output text \
    --include TAGS \
    --query 'tags[?key==`version`].value'

  [ "$status" -eq 0 ]
  [ "$output" = "$VERSION" ]
}
