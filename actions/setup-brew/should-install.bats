#!/usr/bin/env bats

load should-install.sh

function setup() {
  pushd "$BATS_TEST_TMPDIR" >/dev/null
}

function teardown() {
  popd >/dev/null
}

@test "it should not indicate to install if the install variable is false" {
  touch Brewfile

  run should-install Brewfile false

  [ "$status" -eq 0 ]
  [ "$output" = "::set-output name=answer::false" ]
}

@test "it should not indicate to install if the file does not exist" {
  run should-install Brewfile true

  [ "$status" -eq 0 ]
  [ "$output" = "::set-output name=answer::false" ]
}

@test "it should indicate to install if the file does exist and the install variable is true" {
  touch Brewfile

  run should-install Brewfile true

  [ "$status" -eq 0 ]
  [ "$output" = "::set-output name=answer::true" ]
}
