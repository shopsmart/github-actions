#!/usr/bin/env bats

@test "it should have removed /usr/lib/jvm" {
  run [ -f /usr/lib/jvm ]
  [ "$status" -ne 0 ]
}

@test "it should have removed /usr/share/dotnet" {
  run [ -f /usr/share/dotnet ]
  [ "$status" -ne 0 ]
}

@test "it should have removed /usr/share/swift" {
  run [ -f /usr/share/swift ]
  [ "$status" -ne 0 ]
}

@test "it should have removed /usr/local/.ghcup" {
  run [ -f /usr/local/.ghcup ]
  [ "$status" -ne 0 ]
}

@test "it should have removed /usr/local/julia*" {
  run ls /usr/local/julia*
  [ "$status" -ne 0 ]
}

@test "it should have removed /usr/local/lib/android" {
  run [ -f /usr/local/lib/android ]
  [ "$status" -ne 0 ]
}

@test "it should not have removed /usr/local/share/chromium" {
  run [ -f /usr/local/share/chromium ]
  [ "$status" -eq 0 ]
}

@test "it should have removed /opt/microsoft" {
  run [ -f /opt/microsoft ]
  [ "$status" -ne 0 ]
}

@test "it should not have removed /opt/google" {
  run [ -f /opt/google ]
  [ "$status" -eq 0 ]
}

@test "it should have removed /opt/az" {
  run [ -f /opt/az ]
  [ "$status" -ne 0 ]
}

@test "it should have removed /usr/local/share/powershell" {
  run [ -f /usr/local/share/powershell ]
  [ "$status" -ne 0 ]
}
