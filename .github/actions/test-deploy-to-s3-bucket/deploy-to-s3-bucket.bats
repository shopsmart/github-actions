#!/usr/bin/env bats

function setup() {
  :
}

function teardown() {
  :
}

@test "it should have deployed the assets to the s3 bucket" {
  run aws s3 cp --recursive "s3://$S3_BUCKET/$S3_BUCKET_PATH" "$BATS_TEST_TMPDIR"

  [ "$status" -eq 0 ]
  [ -f "$BATS_TEST_TMPDIR/index.html" ]
  [ -f "$BATS_TEST_TMPDIR/style.css" ]
}

@test "it should have set the tag on assets" {
  run aws s3api get-object-tagging --no-cli-pager \
    --bucket "$S3_BUCKET" \
    --key "$S3_BUCKET_PATH/index.html" \
    --query 'TagSet[?Key==`test`].Value' \
    --output text

  [ "$status" -eq 0 ]
  [[ "$output" =~ $S3_TAG ]]

  run aws s3api get-object-tagging --no-cli-pager \
    --bucket "$S3_BUCKET" \
    --key "$S3_BUCKET_PATH/style.css" \
    --query 'TagSet[?Key==`test`].Value' \
    --output text

  [ "$status" -eq 0 ]
  [[ "$output" =~ $S3_TAG ]]
}


@test "it should have set the cache-control metadata" {
  run aws s3api head-object --no-cli-pager \
    --bucket "$S3_BUCKET" \
    --key "$S3_BUCKET_PATH/style.css" \
    --query 'CacheControl' \
    --output text

  [ "$status" -eq 0 ]
  [ "$output" = "$CACHE_CONTROL" ]
}
