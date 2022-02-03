#!/usr/bin/env bats

function setup() {
  :
}

function teardown() {
  :
}

@test "it should have deployed the assets to the s3 bucket" {
  run aws s3 cp --recursive "s3://$S3_BUCKET/$S3_BUCKET_PATH" "$BATS_TEST_TMPDIR"

  echo "$output"

  [ "$status" -eq 0 ]
  [ -f "$BATS_TEST_TMPDIR/index.html" ]
  [ -f "$BATS_TEST_TMPDIR/style.css" ]
}

# @test "it should have set the tag on all assets" {
#   run aws s3api get-object-tagging \
#     --bucket $S3_BUCKET \
#     --key $S3_BUCKET_PATH/index.html \
#     --no-cli-pager \
#   | jq -r '.TagSet | to_entries[] | select(.key == "version")'

#   [ "$status" -eq 0 ]
#   [ "$output" = "$VERSION" ]
# }
