#!/usr/bin/env bats

load deploy-lambda.sh

function setup() {
  export AWS_CMD_FILE="$BATS_TEST_TMPDIR/aws.cmd"
  export -f aws

  export LAMBDA_FUNCTION=lambda
  export LAMBDA_PATH="$BATS_TEST_TMPDIR/lambda"

  mkdir -p "$LAMBDA_PATH"

  pushd "$LAMBDA_PATH" >/dev/null
    echo "export async function handler() { console.log('Hello world'); }" > index.js
  popd >/dev/null

  export ZIP_PATH="$BATS_TEST_TMPDIR/lambda.zip"

  zip "$ZIP_PATH" "$LAMBDA_PATH"
}

function teardown() {
  rm -f "$AWS_CMD_FILE"
}

function aws() {
  echo "$*" >> "$AWS_CMD_FILE"
}

@test "it should require a function name" {
  run deploy-lambda "" "$ZIP_PATH"

  [ "$status" -ne 0 ]
}

@test "it should require a zip path" {
  run deploy-lambda "$FUNCTION_NAME" ""

  [ "$status" -ne 0 ]
}

@test "it should require an s3 bucket and s3 path if no zip file" {
  export S3_BUCKET=my-s3-bucket
  export S3_KEY=''

  run deploy-lambda "$FUNCTION_NAME" ""

  [ "$status" -ne 0 ]
}

@test "it should require the zip to be an actual file" {
  run deploy-lambda "$FUNCTION_NAME" "$BATS_TEST_DIRNAME/nothere.zip"

  [ "$status" -ne 0 ]
}

@test "it should require the zip to be an actual file when expanded" {
  run deploy-lambda "$FUNCTION_NAME" "$BATS_TEST_DIRNAME/*.tgz"

  [ "$status" -ne 0 ]
}

@test "it should upload the zip to lambda" {
  run deploy-lambda "$LAMBDA_FUNCTION" "$ZIP_PATH"

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [[ "$(< "$AWS_CMD_FILE")" =~ "lambda update-function-code --function-name $LAMBDA_FUNCTION --zip-file $zip_file" ]]
}

@test "it should expand wildcards" {
  run deploy-lambda "$LAMBDA_FUNCTION" "$BATS_TEST_TMPDIR/*.zip"

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [[ "$(< "$AWS_CMD_FILE")" =~ "lambda update-function-code --function-name $LAMBDA_FUNCTION --zip-file fileb://$zip_file" ]]
}

@test "it should set s3 options" {
  export S3_BUCKET=my-s3-bucket
  export S3_KEY=my-s3-key

  run deploy-lambda "$LAMBDA_FUNCTION" "$BATS_TEST_TMPDIR/*.zip"

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [[ "$(< "$AWS_CMD_FILE")" =~ "lambda update-function-code --function-name $LAMBDA_FUNCTION --s3-bucket $S3_BUCKET --s3-key $S3_KEY" ]]
}

@test "it should set allow s3 object version" {
  export S3_BUCKET=my-s3-bucket
  export S3_KEY=my-s3-key
  export S3_OBJECT_VERSION=123456

  run deploy-lambda "$LAMBDA_FUNCTION" "$BATS_TEST_TMPDIR/*.zip"

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [[ "$(< "$AWS_CMD_FILE")" =~ "lambda update-function-code --function-name $LAMBDA_FUNCTION --s3-bucket $S3_BUCKET --s3-key $S3_KEY --s3-object-version $S3_OBJECT_VERSION" ]]
}
