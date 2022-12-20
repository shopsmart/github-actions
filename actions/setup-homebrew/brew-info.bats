#!/usr/bin/env bats

load brew-info.sh

function setup() {
  export GITHUB_OUTPUT="$BATS_TEST_TMPDIR/output"
  pushd "$BATS_TEST_TMPDIR" >/dev/null
}

function teardown() {
  popd >/dev/null
}

@test "it should not indicate to install if the install variable is false" {
  touch Brewfile

  run brew-info Brewfile false

  [ "$status" -eq 0 ]
  grep -q 'should-install=false' "$GITHUB_OUTPUT"
}

@test "it should not indicate to install if the file does not exist" {
  run brew-info Brewfile true

  [ "$status" -eq 0 ]
  grep -q 'should-install=false' "$GITHUB_OUTPUT"
}

@test "it should indicate to install if the file does exist and the install variable is true" {
  touch Brewfile

  run brew-info Brewfile true

  [ "$status" -eq 0 ]
  grep -q 'should-install=true' "$GITHUB_OUTPUT"
}

@test "it should output the cache path for homebrew" {
  # Dynamically pull the cache path because it will run on multiple OS
  local cache_path=''
  cache_path="$(brew --cache)"

  run brew-info Brewfile true

  [ "$status" -eq 0 ]
  grep -q "cache-path=$cache_path" "$GITHUB_OUTPUT"
}

@test "it should output the prefix path for homebrew" {
  # Dynamically pull the prefix path because it will run on multiple OS
  local prefix_path=''
  prefix_path="$(brew --prefix)"

  run brew-info Brewfile true

  [ "$status" -eq 0 ]
  grep -q "prefix-path=$prefix_path" "$GITHUB_OUTPUT"
}

@test "it should output the bin paths for homebrew" {
  # Dynamically pull the bin path because it will run on multiple OS
  local prefix_path=''
  prefix_path="$(brew --prefix)"

  run brew-info Brewfile true

  [ "$status" -eq 0 ]
  grep -q "bin-paths=$prefix_path/bin:$prefix_path/sbin" "$GITHUB_OUTPUT"
}
