#!/usr/bin/env bats

function setup() {
  :
}

function teardown() {
  :
}

@test "it should not consider empty string a release" {
  run [ "$EMPTY_STRING_IS_RELEASE" = 'false' ]

  [ "$status" -eq 0 ]
}

@test "it should not consider 'nothere' a release" {
  run [ "$NOTHERE_IS_RELEASE" = 'false' ]

  [ "$status" -eq 0 ]
}

@test "it should consider v2.0.2 a release" {
  run [ "$V2_0_2_IS_RELEASE" = 'true' ]

  [ "$status" -eq 0 ]
}

@test "it should consider v2.0.2-rc.0 a prerelease" {
  run [ "$V2_0_2_RC_0_IS_PRERELEASE" = 'true' ]

  [ "$status" -eq 0 ]
}

@test "it should not consider v2.0.2 a release" {
  run [ "$V2_0_2_RC_0_IS_RELEASE" = 'false' ]

  [ "$status" -eq 0 ]
}
