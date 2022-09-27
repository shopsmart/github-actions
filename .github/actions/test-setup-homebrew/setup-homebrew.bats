#!/usr/bin/env bats

@test "it should have brew installed" {
  run brew --version

  [ "$status" -eq 0 ]
}

@test "it should have installed go" {
  run go version

  [ "$status" -eq 0 ]
}

@test "it should have installed ag" {
  run ag --version

  [ "$status" -eq 0 ]
}
