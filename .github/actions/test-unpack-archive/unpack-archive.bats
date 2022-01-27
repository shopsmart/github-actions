#!/usr/bin/env bats

@test "it should have passed along the destination" {
  [ -n "$DESTINATION" ]
}

@test "it should have passed along the mime type" {
  [ -n "$MIME_TYPE" ]
}

@test "it should have unpacked the archive file" {
  [ -f "$DESTINATION/index.html" ]
  [ -f "$DESTINATION/style.css" ]
}
