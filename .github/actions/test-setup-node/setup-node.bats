#!/usr/bin/env bats

@test "it should have node installed" {
  run node --version

  [ "$status" -eq 0 ]
}

@test "it should have npm installed" {
  run npm --version

  [ "$status" -eq 0 ]
}

@test "it should have installed node_modules" {
  [ -d "$DIRECTORY/node_modules" ]
}

@test "it should have passed along the node version" {
  [ -n "$NODE_VERSION" ]
}
