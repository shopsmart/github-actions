#!/usr/bin/env bats

function setup() {
  :
}

function teardown() {
  :
}

@test "it should have deployed the image to ecr" {
  run docker pull "$ECR_REPOSITORY:$VERSION_TAG"

  [ "$status" -eq 0 ]
}

@test "it should run the correct image" {
  run docker run "$ECR_REPOSITORY:$VERSION_TAG"

  [ "$status" -eq 0 ]
  [ "$output" = "{\"version\": \"$VERSION_TAG\"}" ]
}
