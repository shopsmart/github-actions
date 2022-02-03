#!/usr/bin/env bats

load with-env-vars.sh

function setup() {
  export -f with-env-vars

  export ENV_VARS='FOO=bar
BAR='\''baz'\''
BAZ=&this
QUO=;echo \"$USER\"
'
}

function teardown() {
  unset ENV_VARS
}

@test "it should export environment variables and then exec" {
  run with-env-vars sh -c 'echo "FOO=$FOO, BAR=$BAR, BAZ=$BAZ, QUO=$QUO"'

  echo "$output"

  [ "$status" -eq 0 ]
  [[ "$output" =~ .*"FOO=bar, BAR=baz, BAZ=&this, QUO=;echo \"\$USER\"".* ]]
}
