#!/usr/bin/env bats

@test "it should retag the docker image as variant1" {
  run docker pull "$TARGET_IMAGE_VARIANT1"
  [ "$status" -eq 0 ]
}

@test "it should retag the docker image as variant2" {
  run docker pull "$TARGET_IMAGE_VARIANT2"
  [ "$status" -eq 0 ]
}

@test "it should output the tags it retagged" {
  [ "$TAGS_OUTPUT" = "$TARGET_IMAGE_VARIANT1 $TARGET_IMAGE_VARIANT2" ]
}
