#!/usr/bin/env bats

load upload-assets.sh

function setup() {
  export AWS_CMD_FILE="$BATS_TEST_TMPDIR/aws.cmd"
  export -f aws

  export S3_BUCKET=my-s3-bucket
  export S3_BUCKET_PATH=''
}

function teardown() {
  rm -f "$AWS_CMD_FILE"

  unset CACHE_CONTROL
}

function aws() {
  echo "$*" > "$AWS_CMD_FILE"
}

@test "it should copy to s3 bucket without path" {
  run upload-assets my-path

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [[ "$(< "$AWS_CMD_FILE")" == s3\ cp\ --recursive\ my-path/\ s3://my-s3-bucket/ ]]
}

@test "it should copy to s3 bucket with path" {
  export S3_BUCKET_PATH=my-s3-path

  run upload-assets my-path

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [[ "$(< "$AWS_CMD_FILE")" == s3\ cp\ --recursive\ my-path/\ s3://my-s3-bucket/my-s3-path/ ]]
}

@test "it should set the cache-control" {
  export CACHE_CONTROL='max-age=36000'

  run upload-assets my-path

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [[ "$(< "$AWS_CMD_FILE")" == s3\ cp\ --recursive\ my-path/\ s3://my-s3-bucket/\ --cache-control\ max-age=36000 ]]
}
