#!/usr/bin/env bats

load get-info.sh

function setup() {
    export GITHUB_OUTPUT="$BATS_TEST_TMPDIR/output"
}

function teardown() {
    :
}

@test "it should not change EMOJI if set" {
    EMOJI=test
    run get-info

    [ "$status" -eq 0 ]
    grep -q 'emoji=test' "$GITHUB_OUTPUT"
}
