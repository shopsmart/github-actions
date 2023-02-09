#!/usr/bin/env bats

function setup() {
  export ECR_REPOSITORY_NAME="${ECR_REPOSITORY##*/}"
}

function teardown() {
  :
}

@test "it should have deployed the image to ecr" {
  run docker pull "$ECR_REPOSITORY"

  [ "$status" -eq 0 ]
}

@test "it should run the correct image" {
  run docker run "$ECR_REPOSITORY"

  [ "$status" -eq 0 ]
  [ "$output" = "{\"version\": \"$VERSION_TAG\"}" ]
}
