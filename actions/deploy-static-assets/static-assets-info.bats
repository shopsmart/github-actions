#!/usr/bin/env bats

load static-assets-info.sh

function setup() {
  export AWS_ACCESS_KEY_ID=''
  export AWS_SECRET_ACCESS_KEY=''
}

function teardown() {
  :
}

@test "it should configure aws credentials" {
  export AWS_ACCESS_KEY_ID='foo'
  export AWS_SECRET_ACCESS_KEY='bar'

  run static-assets-info

  [ "$status" -eq 0 ]
  [[ "$output" =~ .*::set-output\ name=configure-aws-credentials::true ]]
}

@test "it should not configure aws credentials" {
  run static-assets-info

  [ "$status" -eq 0 ]
  [[ "$output" =~ .*::set-output\ name=configure-aws-credentials::false ]]
}

@test "it should error because access key id is missing" {
  export AWS_SECRET_ACCESS_KEY='bar'

  run static-assets-info

  [ "$status" -ne 0 ]
}

@test "it should error because secret access key is missing" {
  export AWS_ACCESS_KEY_ID='foo'

  run static-assets-info

  [ "$status" -ne 0 ]
}
