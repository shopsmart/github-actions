#!/usr/bin/env bats

load determine-version.sh

function setup() {
  export GITHUB_OUTPUT="$BATS_TEST_TMPDIR/output"
  pushd "$BATS_TEST_TMPDIR" >/dev/null
}

function teardown() {
   popd >/dev/null
}

@test "it should determine version from input" {
  run determine-version - 1.1.1

  [ $status -eq 0 ]
  grep -q 'version=1.1.1' "$GITHUB_OUTPUT"
}

@test "it should determine version from version file" {
  echo 1.1.1 > .node-version

  run determine-version node

  [ $status -eq 0 ]
  grep -q 'version=1.1.1' "$GITHUB_OUTPUT"
}

@test "it should determine node version from nvmrc file" {
  echo v1.1.1 > .nvmrc

  run determine-version node

  [ $status -eq 0 ]
  grep -q 'version=1.1.1' "$GITHUB_OUTPUT"
}
