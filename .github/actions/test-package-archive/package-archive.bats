#!/usr/bin/env bats

function setup() {
  :
}

function teardown() {
  :
}

@test "it should package the archive file" {
  [ -f "$DESTINATION/archive.tgz" ]

  run tar -xf "$DESTINATION/archive.tgz" -C "$BATS_TEST_TMPDIR" .

  [ "$status" -eq 0 ]
  [ -f "$BATS_TEST_TMPDIR/index.html" ]
  [ -f "$BATS_TEST_TMPDIR/style.css" ]
}

@test "it should have passed on the filename" {
  [ -n "$FILENAME" ]
}
