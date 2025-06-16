#!/usr/bin/env bats

load retag-docker-image.sh

function docker() {
  export GITHUB_OUTPUT="$BATS_TEST_TMPDIR/output"
  echo "docker $*" >> "$DOCKER_CMD_FILE"
}

function setup() {
  export DOCKER_CMD_FILE="$BATS_TEST_TMPDIR/docker.cmd"

  export -f docker
}

function teardown() {
  rm -f "$DOCKER_CMD_FILE"
}

@test "should error out if no source image is provided" {
  run retag-docker-image

  [ "$status" -ne 0 ]
  [ "${lines[0]}" = "Usage: $0 <source-image> [<target-image1> <target-image2> ...]" ]
}

@test "should not error out if no target images are provided" {
  run retag-docker-image "source-image"

  [ "$status" -eq 0 ]
}

@test "should retag a single target image" {
  run retag-docker-image "source-image" "target-image"

  [ "$status" -eq 0 ]
  [ -f "$DOCKER_CMD_FILE" ]
  [ "$(< "$DOCKER_CMD_FILE")" = "docker tag source-image target-image" ]
}

@test "should retag multiple target images" {
  run retag-docker-image "source-image" "target-image1" "target-image2"

  [ "$status" -eq 0 ]
  [ -f "$DOCKER_CMD_FILE" ]
  [[ "$(< "$DOCKER_CMD_FILE")" =~ "docker tag source-image target-image1".* ]]
  [[ "$(< "$DOCKER_CMD_FILE")" =~ .*"docker tag source-image target-image2" ]]
  [[ "$(< "$GITHUB_OUTPUT")" =~ "tags=target-image1 target-image2" ]]
}

@test "should read target images from TARGETS environment variable" {
  export TARGETS="target-image1
target-image2"

  run retag-docker-image "source-image"

  [ "$status" -eq 0 ]
  [ -f "$DOCKER_CMD_FILE" ]
  [[ "$(< "$DOCKER_CMD_FILE")" =~ "docker tag source-image target-image1".* ]]
  [[ "$(< "$DOCKER_CMD_FILE")" =~ .*"docker tag source-image target-image2" ]]
  [[ "$(< "$GITHUB_OUTPUT")" =~ "tags=target-image1 target-image2" ]]
}
