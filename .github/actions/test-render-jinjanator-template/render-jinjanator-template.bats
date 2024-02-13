#!/usr/bin/env bats

function setup() {
  :
}

function teardown() {
  :
}

@test "it should have rendered the expected task-definition.yml" {
  sed 's/{{ tag }}/'"$VERSION_TAG"/g "$BATS_TEST_DIRNAME/expected.yml" > "$BATS_TEST_TMPDIR/expected.yml"

  run diff -y "$BATS_TEST_TMPDIR/expected.yml" "$OUTPUT_FILE"

  [ "$status" -eq 0 ]
}
