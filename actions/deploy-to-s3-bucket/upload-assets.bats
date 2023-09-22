#!/usr/bin/env bats

load upload-assets.sh

function setup() {
  export AWS_CMD_FILE="$BATS_TEST_TMPDIR/aws.cmd"
  export -f aws

  export S3_BUCKET=my-s3-bucket
  export S3_BUCKET_PATH=''

  export WORKING_DIRECTORY="$BATS_TEST_TMPDIR/working-directory"
  mkdir -p "$WORKING_DIRECTORY"
  pushd "$WORKING_DIRECTORY" &>/dev/null

  mkdir -p my-path
}

function teardown() {
  popd &>/dev/null
  rm -f "$AWS_CMD_FILE"
}

function aws() {
  echo "$*" > "$AWS_CMD_FILE"
}

@test "it should error out if path does not exist" {
  rmdir my-path

  run upload-assets my-path/
}

@test "it should attach the slash if path is a directory" {
  run upload-assets my-path

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [[ "$(< "$AWS_CMD_FILE")" =~ s3\ cp\ (.*\ )?my-path/\ s3://my-s3-bucket/ ]]
}

@test "it should attach use the --recursive option if path is a directory" {
  run upload-assets my-path

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [[ "$(< "$AWS_CMD_FILE")" =~ s3\ cp\ --recursive\ .* ]]
}

@test "it should not attach the slash nor options if path is a file" {
  touch my-path.txt

  run upload-assets my-path.txt

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [[ "$(< "$AWS_CMD_FILE")" == s3\ cp\ my-path.txt\ s3://my-s3-bucket/ ]]
}

@test "it should not add additional slashes if slashes are already in the paths" {
  export S3_BUCKET_PATH=my-s3-path/

  run upload-assets my-path/

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [[ "$(< "$AWS_CMD_FILE")" =~ s3\ cp\ (.*\ )?my-path/\ s3://my-s3-bucket/my-s3-path/ ]]
}

@test "it should not add a slash if path is a file and s3-path was provided" {
  export S3_BUCKET_PATH=my-path.foo

  touch my-path.txt

  run upload-assets "$PWD/my-path.txt"

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [[ "$(< "$AWS_CMD_FILE")" =~ s3\ cp\ (.*\ )?"$PWD/my-path.txt"\ s3://my-s3-bucket/my-path.foo ]]
}

@test "it should not add an extra slash if path is a file and s3-path was provided" {
  export S3_BUCKET_PATH=my-path/

  touch my-path.txt

  run upload-assets "$PWD/my-path.txt"

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [[ "$(< "$AWS_CMD_FILE")" =~ s3\ cp\ (.*\ )?"$PWD/my-path.txt"\ s3://my-s3-bucket/my-path/ ]]
}
