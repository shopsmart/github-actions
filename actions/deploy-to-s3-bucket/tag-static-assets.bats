#!/usr/bin/env bats

load tag-static-assets.sh

function setup() {
  export AWS_CMD_FILE="$BATS_TEST_TMPDIR/aws.cmd"
  export -f aws

  export S3_BUCKET=my-s3-bucket
  export S3_BUCKET_PATH=my-path
  export S3_TAGS='Foo=bar
team=my-team
owner=anonymous
'
  export ASSETS_PATH="$BATS_TEST_TMPDIR/static-assets"

  mkdir -p "$ASSETS_PATH"

  pushd "$ASSETS_PATH" >/dev/null
    echo "<html><head></head><body>Hello world</body></html>" > index.html
    echo "head p { color: black; }" > style.css
  popd >/dev/null
}

function teardown() {
  rm -f "$AWS_CMD_FILE"
}

function aws() {
  echo "$*" >> "$AWS_CMD_FILE"
}

@test "it should error out if no path is provided" {
  run tag-static-assets

  [ "$status" -ne 0 ]
}

@test "it should tag all assets within path" {
  run tag-static-assets "$ASSETS_PATH"

  tagset="TagSet=[{Key='Foo',Value='bar'},{Key='team',Value='my-team'},{Key='owner',Value='anonymous'}]"

  cat "$AWS_CMD_FILE"

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [[ "$(< "$AWS_CMD_FILE")" =~ "s3api put-object-tagging --bucket my-s3-bucket --key my-path/index.html --tagging $tagset".* ]]
  [[ "$(< "$AWS_CMD_FILE")" =~ .*"s3api put-object-tagging --bucket my-s3-bucket --key my-path/style.css --tagging $tagset" ]]
}

@test "it should tag all assets within path without S3_BUCKET_PATH" {
  unset S3_BUCKET_PATH

  run tag-static-assets "$ASSETS_PATH"

  tagset="TagSet=[{Key='Foo',Value='bar'},{Key='team',Value='my-team'},{Key='owner',Value='anonymous'}]"

  cat "$AWS_CMD_FILE"

  [ "$status" -eq 0 ]
  [ -f "$AWS_CMD_FILE" ]
  [[ "$(< "$AWS_CMD_FILE")" =~ "s3api put-object-tagging --bucket my-s3-bucket --key index.html --tagging $tagset".* ]]
  [[ "$(< "$AWS_CMD_FILE")" =~ .*"s3api put-object-tagging --bucket my-s3-bucket --key style.css --tagging $tagset" ]]
}

@test "it should do nothing with no tags" {
  export S3_TAGS=''

  run tag-static-assets "$ASSETS_PATH"

  [ "$status" -eq 0 ]
  ! [ -f "$AWS_CMD_FILE" ]
}
