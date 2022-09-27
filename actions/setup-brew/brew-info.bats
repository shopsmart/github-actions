#!/usr/bin/env bats

load brew-info.sh

function setup() {
  pushd "$BATS_TEST_TMPDIR" >/dev/null
}

function teardown() {
  popd >/dev/null
}

@test "it should not indicate to install if the install variable is false" {
  touch Brewfile

  run brew-info Brewfile false

  [ "$status" -eq 0 ]
  [[ "$output" =~ .*"::set-output name=should-install::false".* ]]
}

@test "it should not indicate to install if the file does not exist" {
  run brew-info Brewfile true

  [ "$status" -eq 0 ]
  [[ "$output" =~ .*"::set-output name=should-install::false".* ]]
}

@test "it should indicate to install if the file does exist and the install variable is true" {
  touch Brewfile

  run brew-info Brewfile true

  [ "$status" -eq 0 ]
  [[ "$output" =~ .*"::set-output name=should-install::true".* ]]
}

@test "it should output the cache paths for homebrew" {
  # Dynamically pull the cache path because it will run on multiple OS
  local cache_path=''
  cache_path="$(brew --cache)"

  run brew-info Brewfile true

  [ "$status" -eq 0 ]
  [[ "$output" =~ .*"::set-output name=cache-paths::${cache_path}/*--*\\n${cache_path}/downloads/*".* ]]
}

@test "it should output the prefix path for homebrew" {
  # Dynamically pull the prefix path because it will run on multiple OS
  local prefix_path=''
  prefix_path="$(brew --prefix)"

  run brew-info Brewfile true

  [ "$status" -eq 0 ]
  [[ "$output" =~ .*"::set-output name=prefix-path::${prefix_path}".* ]]
}

@test "it should output the bin paths for homebrew" {
  # Dynamically pull the bin path because it will run on multiple OS
  local prefix_path=''
  prefix_path="$(brew --prefix)"

  run brew-info Brewfile true

  [ "$status" -eq 0 ]
  [[ "$output" =~ .*"::set-output name=bin-paths::${prefix_path}/bin:${prefix_path}/sbin".* ]]
}
