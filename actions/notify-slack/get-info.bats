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

@test "it should not change MESSAGE if set" {
    MESSAGE=test
    run get-info

    [ "$status" -eq 0 ]
    grep -q 'message=test' "$GITHUB_OUTPUT"
}

@test "it should set EMOJI to large_green_circle for status success" {
    STATUS=success
    run get-info

    [ "$status" -eq 0 ]
    grep -q 'emoji=large_green_circle' "$GITHUB_OUTPUT"
}

@test "it should set EMOJI to red_circle for status failure" {
    STATUS=failure
    run get-info

    [ "$status" -eq 0 ]
    grep -q 'emoji=red_circle' "$GITHUB_OUTPUT"
}

@test "it should set EMOJI to large_blue_circle for status started" {
    STATUS=started
    run get-info

    [ "$status" -eq 0 ]
    grep -q 'emoji=large_blue_circle' "$GITHUB_OUTPUT"
}

@test "it should set EMOJI to white_circle for any other status" {
    STATUS=unknown
    run get-info

    [ "$status" -eq 0 ]
    grep -q 'emoji=white_circle' "$GITHUB_OUTPUT"
}

@test "it should set MESSAGE to default value if not set and STATUS is not started" {
    TYPE=test
    APPLICATION=github-actions
    VERSION=1.0
    ENVIRONMENT=production
    STATUS=success
    run get-info

    [ "$status" -eq 0 ]
    grep -q 'message=A test for github-actions:1.0 to production resulted in success' "$GITHUB_OUTPUT"
}

@test "it should set MESSAGE to custom value if not set and STATUS is started" {
    TYPE=test
    APPLICATION=github-actions
    VERSION=2.0
    ENVIRONMENT=staging
    STATUS=started
    run get-info

    [ "$status" -eq 0 ]
    grep -q 'message=A test has been started for github-actions:2.0 to staging' "$GITHUB_OUTPUT"
}

@test "it should set TIMESTAMP to current timestamp" {
    run get-info

    [ "$status" -eq 0 ]
    timestamp=$(grep -oE 'timestamp=[0-9]+' "$GITHUB_OUTPUT" | cut -d= -f2)
    now=$(date +%s)
    [ "$timestamp" -le "$now" ]
}
