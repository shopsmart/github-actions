#!/usr/bin/env bats

@test "it have retagged the docker image as variant1" {
  docker pull "$TARGET_IMAGE_VARIANT1"
  [ "$status" -eq 0 ]
}

@test "it have retagged the docker image as variant2" {
  docker pull "$TARGET_IMAGE_VARIANT2"
  [ "$status" -eq 0 ]
}
