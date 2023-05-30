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

@test "it should consider cli/cli v2.3.0 a release" {
  run [ "$CLI_CLI_V2_3_0_IS_RELEASE" = 'true' ]

  [ "$status" -eq 0 ]
}
