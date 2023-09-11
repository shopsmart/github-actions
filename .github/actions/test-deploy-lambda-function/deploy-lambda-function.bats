#!/usr/bin/env bats

function setup() {
  export FUNCTION_NAME="${FUNCTION_ARN##*/}"
}

function teardown() {
  :
}

@test "it should have deployed the code to lambda" {
  local outfile="$BATS_TEST_TMPDIR/out.json"
  run aws lambda invoke --no-cli-pager \
    --function-name "$FUNCTION_NAME" \
    --output text \
    "$outfile"

  # example payload
  # {"statusCode":200,"body":"{\"version\":\"14460a97b6767f6009d732af022b21698a41342a\"}","headers":{"Content-Type":"application/json"}}

  [ "$status" -eq 0 ]
  [[ "$(< "$outfile")" =~ .*'\"version\":\"'"$VERSION_TAG"'\"'.* ]]
}

@test "it should have tagged the lambda version" {
  run aws lambda list-tags --no-cli-pager \
    --resource "$FUNCTION_ARN" \
    --query 'Tags.version' \
    --output text

  [ "$status" -eq 0 ]
  [ "$output" = "$VERSION_TAG" ]
}

@test "it should have uploaded the artifact to s3" {
  local filename=''
  filename="$(basename "$S3_KEY")"

  run aws s3 ls --no-cli-pager \
    "s3://$S3_BUCKET/$S3_KEY"

  [ "$status" -eq 0 ]
  [ -n "$output" ]
  [[ "$output" =~ .*\ "${filename}"$ ]]
}
