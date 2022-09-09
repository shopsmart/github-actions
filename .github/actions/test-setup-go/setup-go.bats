#!/usr/bin/env bats

@test "it should have go installed" {
  run go version

  [ "$status" -eq 0 ]
}

@test "it should have installed go modules" {
  [ -d "$GOPATH/src/golang.org/x" ]
}

@test "it should have passed along the go version" {
  [ -n "$GO_VERSION" ]
}
