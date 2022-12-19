#!/usr/bin/env bats

load package-archive.sh

function setup() {
  export GITHUB_OUTPUT="$BATS_TEST_TMPDIR/output"
  export BUILD_DIRECTORY="$BATS_TEST_TMPDIR/build"

  mkdir -p "$BUILD_DIRECTORY"

  pushd "$BATS_TEST_TMPDIR" >/dev/null

  echo "<html><head></head><body>Hello world</body></html>" > build/index.html
  echo "head p { color: black; }" > build/style.css
}

function teardown() {
  popd >/dev/null

  unset EXTENSION
}

@test "it should error if build directory does not exist" {
  rm -rf "$BUILD_DIRECTORY"

  run package-archive build tgz assets

  [ "$status" -ne 0 ]
}

@test "it should infer the filename from the build directory" {
  run package-archive build

  [ "$status" -eq 0 ]
  [ -f "$BATS_TEST_TMPDIR/build.tgz" ]
  grep -q 'filename=build.tgz' "$GITHUB_OUTPUT"
}

@test "it should use the EXTENSION environment variable for extension" {
  export EXTENSION=tar.gz

  run package-archive build

  [ "$status" -eq 0 ]
  [ -f "$BATS_TEST_TMPDIR/build.tar.gz" ]
  grep -q 'filename=build.tar.gz' "$GITHUB_OUTPUT"
}

@test "it should package build directory into gzipped tarball" {
  run package-archive build tgz assets

  [ "$status" -eq 0 ]
  [ -f "$BATS_TEST_TMPDIR/assets.tgz" ]
  grep -q 'filename=assets.tgz' "$GITHUB_OUTPUT"

  mkdir -p "$BATS_TEST_TMPDIR/unpackaged"
  tar -zxf "$BATS_TEST_TMPDIR/assets.tgz" -C "$BATS_TEST_TMPDIR/unpackaged"
  [ -f "$BATS_TEST_TMPDIR/unpackaged/index.html" ]
  [ -f "$BATS_TEST_TMPDIR/unpackaged/style.css" ]
}

@test "it should package build directory into tarball" {
  run package-archive build tar assets

  [ "$status" -eq 0 ]
  [ -f "$BATS_TEST_TMPDIR/assets.tar" ]
  grep -q 'filename=assets.tar' "$GITHUB_OUTPUT"

  mkdir -p "$BATS_TEST_TMPDIR/unpackaged"
  tar -xf "$BATS_TEST_TMPDIR/assets.tar" -C "$BATS_TEST_TMPDIR/unpackaged"
  [ -f "$BATS_TEST_TMPDIR/unpackaged/index.html" ]
  [ -f "$BATS_TEST_TMPDIR/unpackaged/style.css" ]
}


@test "it should package build directory into zip" {
  run package-archive build zip assets

  [ "$status" -eq 0 ]
  [ -f "$BATS_TEST_TMPDIR/assets.zip" ]
  grep -q 'filename=assets.zip' "$GITHUB_OUTPUT"

  mkdir -p "$BATS_TEST_TMPDIR/unpackaged"
  unzip "$BATS_TEST_TMPDIR/assets.zip" -d "$BATS_TEST_TMPDIR/unpackaged"
  [ -f "$BATS_TEST_TMPDIR/unpackaged/index.html" ]
  [ -f "$BATS_TEST_TMPDIR/unpackaged/style.css" ]
}
