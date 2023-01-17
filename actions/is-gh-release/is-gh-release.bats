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
  if [ "$1 $2" = "release view" ]; then
    if [ "$3" = v1.0.0 ]; then
      echo "release found"
      # gh actually outputs the release notes,
      # but we do not make use of any of it
    else
      echo "release not found"
      return 1
    fi
  elif [ "$1 $2" = "release list" ]; then
    local tab=$'\t'
    echo "v1.0.1-rc.9: January 17, 2023 11:45 AM${tab}Pre-release${tab}v1.0.1-rc.9${tab}about 12 minutes ago
December 13 AM - First Release${tab}Latest${tab}v1.0.0${tab}about 1 month ago"
  fi
}

@test "it should not consider a blank string a release" {
  run is-gh-release

  [ "$status" -eq 0 ]
  [ -f "$GITHUB_OUTPUT" ]
  grep -q 'is-release=false' "$GITHUB_OUTPUT"
}

@test "it should not consider a release if the gh cli says it is not found" {
  run is-gh-release nothere

  [ "$status" -eq 0 ]
  [ -f "$GITHUB_OUTPUT" ]
  grep -q 'is-release=false' "$GITHUB_OUTPUT"
}

@test "it should consider a release if the gh cli says it is found" {
  run is-gh-release v1.0.0

  [ "$status" -eq 0 ]
  [ -f "$GITHUB_OUTPUT" ]
  grep -q 'is-release=true' "$GITHUB_OUTPUT"
}

@test "it should consider a prerelease if the gh cli lists it but not found it with view" {
  run is-gh-release v1.0.1-rc.9

  [ "$status" -eq 0 ]
  [ -f "$GITHUB_OUTPUT" ]
  grep -q 'is-release=false' "$GITHUB_OUTPUT"
  grep -q 'is-prerelease=true' "$GITHUB_OUTPUT"
}

@test "it should not consider it a prerelease if the gh cli does not list it" {
  run is-gh-release v1.0.1-rc.8

  [ "$status" -eq 0 ]
  [ -f "$GITHUB_OUTPUT" ]
  grep -q 'is-release=false' "$GITHUB_OUTPUT"
  grep -q 'is-prerelease=false' "$GITHUB_OUTPUT"
}
