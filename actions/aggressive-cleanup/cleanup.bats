#!/usr/bin/env bats

load cleanup.sh

function sudo() {
  echo "sudo $*" >> "$SUDO_CMD_FILE"
}

function setup() {
  export SUDO_CMD_FILE="$BATS_TEST_DIRNAME/sudo.cmd"
  export -f sudo
}

function teardown() {
  rm -f "$SUDO_CMD_FILE"
}

@test "it should remove all directories when no arguments are given" {
  run cleanup

  [ "$status" -eq 0 ]
  [ -f "$SUDO_CMD_FILE" ]
  local expected_commands=(
    "sudo rm -rf /usr/lib/jvm"
    "sudo rm -rf /usr/share/dotnet"
    "sudo rm -rf /usr/share/swift"
    "sudo rm -rf /usr/local/.ghcup"
    "sudo rm -rf /usr/local/julia*"
    "sudo rm -rf /usr/local/lib/android"
    "sudo rm -rf /usr/local/share/chromium"
    "sudo rm -rf /opt/microsoft"
    "sudo rm -rf /opt/google"
    "sudo rm -rf /opt/az"
    "sudo rm -rf /usr/local/share/powershell"
  )
  for cmd in "${expected_commands[@]}"; do
    grep -q "$cmd" "$SUDO_CMD_FILE"
  done
}

@test "it should skip specified directories" {
    run cleanup java dotnet

    [ "$status" -eq 0 ]
    [ -f "$SUDO_CMD_FILE" ]
    grep -qv "sudo rm -rf /usr/lib/jvm" "$SUDO_CMD_FILE"
    grep -qv "sudo rm -rf /usr/share/dotnet" "$SUDO_CMD_FILE"
}
