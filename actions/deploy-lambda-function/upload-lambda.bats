#!/usr/bin/env bats

load upload-lambda.sh

function setup() {
  export AWS_CMD_FILE="$BATS_TEST_TMPDIR/aws.cmd"
  export -f aws

  export GITHUB_OUTPUT="$BATS_TEST_TMPDIR/output.txt"

  export ZIP_FILE="$BATS_TEST_TMPDIR/archive.zip"
  touch "$ZIP_FILE"

  export S3_BUCKET=my-s3-bucket
}

function teardown() {
  rm -f "$AWS_CMD_FILE"
}

function aws() {
  echo "$*" > "$AWS_CMD_FILE"
}

@test "it should require the zip file" {
  run upload-lambda

  [ "$status" -ne 0 ]
}

@test "it should error out if the zip file does not exist" {
  run upload-lambda "$BATS_TEST_TMPDIR/nothere.zip"

  [ "$status" -ne 0 ]
}

@test "it should require the s3 bucket" {
  run upload-lambda "$ZIP_FILE"

  [ "$status" -ne 0 ]
}

@test "it should default the s3 key to the name of the file" {
  S3_KEY="$(basename "$ZIP_FILE")"

  run upload-lambda "$ZIP_FILE" "$S3_BUCKET"

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [ "$(< "$AWS_CMD_FILE")" = "s3 cp $ZIP_FILE s3://$S3_BUCKET/$S3_KEY" ]
  [ -f "$GITHUB_OUTPUT" ]
  [ "$(< "$GITHUB_OUTPUT")" = "s3-key=$S3_KEY" ]
}

@test "it should allow the s3-key to be provided" {
  S3_KEY=my-path/my-artifact.zip

  run upload-lambda "$ZIP_FILE" "$S3_BUCKET" "$S3_KEY"

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [ "$(< "$AWS_CMD_FILE")" = "s3 cp $ZIP_FILE s3://$S3_BUCKET/$S3_KEY" ]
  [ -f "$GITHUB_OUTPUT" ]
  [ "$(< "$GITHUB_OUTPUT")" = "s3-key=$S3_KEY" ]
}

@test "it should toss out an extra slash" {
  S3_KEY=my-path/my-artifact.zip

  run upload-lambda "$ZIP_FILE" "$S3_BUCKET" "/$S3_KEY"

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [ "$(< "$AWS_CMD_FILE")" = "s3 cp $ZIP_FILE s3://$S3_BUCKET/$S3_KEY" ]
  [ -f "$GITHUB_OUTPUT" ]
  [ "$(< "$GITHUB_OUTPUT")" = "s3-key=/$S3_KEY" ]
}
