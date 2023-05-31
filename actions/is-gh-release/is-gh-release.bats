#!/usr/bin/env bats

load is-gh-release.sh

function setup() {
  export GH_CMD_FILE="$BATS_TEST_TMPDIR/gh.cmd"
  export GITHUB_OUTPUT="$BATS_TEST_TMPDIR/output"
}

function teardown() {
  :
}

function gh() {
  echo "$*" >> "$GH_CMD_FILE"
  shift 2 # -R "$REPOSITORY"
  if [ "$1 $2" = "release view" ]; then
    if [[ "$3" =~ v.* ]]; then
      echo "release found"
      # gh actually outputs the release notes,
      # but we do not make use of any of it
    else
      echo "release not found"
      return 1
    fi
  fi
}

@test "it should not consider a blank string a release" {
  run is-gh-release
}

@test "it should not consider a release if the gh cli says it is not found" {
  run is-gh-release nothere

  [ "$status" -eq 0 ]
  [ -f "$GITHUB_OUTPUT" ]
  [ "$(< "$GITHUB_OUTPUT")" = 'is-release=false' ]
}

@test "it should consider a release if the gh cli says it is found" {
  run is-gh-release v1.0.0

  [ "$status" -eq 0 ]
  [ -f "$GITHUB_OUTPUT" ]
  [ "$(< "$GITHUB_OUTPUT")" = 'is-release=true' ]
}
