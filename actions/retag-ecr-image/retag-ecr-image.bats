#!/usr/bin/env bats

load retag-ecr-image.sh

function aws() {
  echo "aws $*" >> "$AWS_CMD_FILE"
}

function setup() {
  export GITHUB_OUTPUT="$BATS_TEST_TMPDIR/output"
  export AWS_CMD_FILE="$BATS_TEST_TMPDIR/aws.cmd"

  export -f aws
}

function teardown() {
  rm -f "$AWS_CMD_FILE"
}

@test "it should error out if no source image is provided" {
  run retag-ecr-image

  [ "$status" -ne 0 ]
  [ "${lines[0]}" = "Usage: $0 <source-image> [<target-image1> <target-image2> ...]" ]
}

@test "it should not error out if no target images are provided" {
  run retag-ecr-image "source-image:1.2.3"

  [ "$status" -eq 0 ]
}

@test "it should error out if source image format is invalid" {
  run retag-ecr-image "invalid-image-format"

  [ "$status" -ne 0 ]
  [[ "${lines[0]}" =~ .*"[ERROR] Invalid source image format: 'invalid-image-format'. Expected format: <registry>/<repository>:<tag>" ]]
}

@test "it should error out if source image does not exist" {
  function aws() {
    echo "aws $*" >> "$AWS_CMD_FILE"
    if [ "$1" = "ecr" ] && [ "$2" = "batch-get-image" ]; then
      return 1
    fi
  }
  export -f aws

  run retag-ecr-image "nonexistent-image:1.2.3" "target-image"

  [ "$status" -ne 0 ]
  [[ "${lines[*]}" =~ .*"[ERROR] Source image 'nonexistent-image:1.2.3' does not exist or cannot be pulled." ]]
}

@test "it should retag a single target image" {
  run retag-ecr-image "source-image:1.2.3" "target-image:1.2.4"

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [[ "$(< "$AWS_CMD_FILE")" =~ .*"aws ecr batch-get-image".* ]]
  [[ "$(< "$AWS_CMD_FILE")" =~ .*"aws ecr put-image --repository-name target-image --image-tag 1.2.4" ]]
}

@test "it should retag multiple target images" {
  run retag-ecr-image "source-image:1.2.3" "target-image:1" "target-image:2"

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [[ "$(< "$AWS_CMD_FILE")" =~ .*"aws ecr put-image --repository-name target-image --image-tag 1".* ]]
  [[ "$(< "$AWS_CMD_FILE")" =~ .*"aws ecr put-image --repository-name target-image --image-tag 2".* ]]
  [[ "$(< "$GITHUB_OUTPUT")" =~ "tags=target-image:1 target-image:2" ]]
}

@test "it should error out if target image format is invalid" {
  run retag-ecr-image "source-image:1.2.3" "invalid-target-image"

  [ "$status" -ne 0 ]
  [[ "${lines[*]}" =~ .*"[ERROR] Invalid target image format: 'invalid-target-image'. Expected format: <registry>/<repository>:<tag>".* ]]
  [ -f "$AWS_CMD_FILE" ]
  [[ ! "$(< "$AWS_CMD_FILE")" =~ .*"aws ecr put-image".* ]]
}

@test "it should continue on target put-image failure" {
  function aws() {
    echo "aws $*" >> "$AWS_CMD_FILE"
    if [[ "$1" == ecr && "$2" == put-image && "$3" == --repository-name && "$4" == target-image && "$5" == --image-tag && "$6" == 1 ]]; then
      return 1  # Simulate failure for target-image:1
    fi
  }
  export -f aws

  run retag-ecr-image "source-image:1.2.3" "target-image:1" "target-image:2"
  [ "$status" -eq 2 ]
  [[ "${lines[*]}" =~ .*"[ERROR] Failed to push target-image:1.".* ]]
  [ -f "$AWS_CMD_FILE" ]
  [[ "$(< "$AWS_CMD_FILE")" =~ .*"aws ecr put-image --repository-name target-image --image-tag 1".* ]]
  [[ "$(< "$AWS_CMD_FILE")" =~ .*"aws ecr put-image --repository-name target-image --image-tag 2".* ]]
  [[ "$(< "$GITHUB_OUTPUT")" =~ "tags=target-image:2" ]]
}

@test "it should read target images from TARGETS environment variable" {
  export TARGETS="target-image:1
target-image:2"

  run retag-ecr-image "source-image:1.2.3"

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [[ "$(< "$AWS_CMD_FILE")" =~ .*"aws ecr put-image --repository-name target-image --image-tag 1".* ]]
  [[ "$(< "$AWS_CMD_FILE")" =~ .*"aws ecr put-image --repository-name target-image --image-tag 2".* ]]
  [[ "$(< "$GITHUB_OUTPUT")" =~ "tags=target-image:1 target-image:2" ]]
}
