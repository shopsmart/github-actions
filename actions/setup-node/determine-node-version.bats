#!/usr/bin/env bats

load determine-node-version.sh

function setup() {
  : # Nothing
}

function teardown() {
  unset NODE_VERSION
}

@test "it should not be able to determine node version" {
  pushd "$BATS_TEST_TMPDIR" >/dev/null
  run determine-node-version
  popd >/dev/null

  [ $status -eq 1 ]
}

@test "it should use the provided node version" {
  pushd "$BATS_TEST_TMPDIR" >/dev/null
  export NODE_VERSION=10.x

  run determine-node-version
  popd >/dev/null

  [ $status -eq 0 ]
  [[ "$output" =~ .*::set-output\ name=node-version::10\.x.* ]]
}

@test "it should use the node version from .nvmrc" {
  pushd "$BATS_TEST_TMPDIR" >/dev/null
  echo v10.x > .nvmrc

  run determine-node-version
  popd >/dev/null

  [ $status -eq 0 ]
  [[ "$output" =~ .*::set-output\ name=node-version::10\.x.* ]]
}

@test "it should use the node version from .node-version" {
  pushd "$BATS_TEST_TMPDIR" >/dev/null
  echo 10.x > .node-version

  run determine-node-version
  popd >/dev/null

  [ $status -eq 0 ]
  [[ "$output" =~ .*::set-output\ name=node-version::10\.x.* ]]
}
