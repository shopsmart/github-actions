#!/usr/bin/env bats

load package-archive.sh

function setup() {
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
  [[ "$output" =~ .*"::set-output name=filename::build.tgz".* ]]
}

@test "it should use the EXTENSION environment variable for extension" {
  export EXTENSION=tar.gz

  run package-archive build

  [ "$status" -eq 0 ]
  [ -f "$BATS_TEST_TMPDIR/build.tar.gz" ]
  [[ "$output" =~ .*"::set-output name=filename::build.tar.gz".* ]]
}

@test "it should package build directory into gzipped tarball" {
  run package-archive build tgz assets

  [ "$status" -eq 0 ]
  [ -f "$BATS_TEST_TMPDIR/assets.tgz" ]
  [[ "$output" =~ .*"::set-output name=filename::assets.tgz".* ]]

  mkdir -p "$BATS_TEST_TMPDIR/unpackaged"
  tar -zxf "$BATS_TEST_TMPDIR/assets.tgz" -C "$BATS_TEST_TMPDIR/unpackaged"
  [ -f "$BATS_TEST_TMPDIR/unpackaged/index.html" ]
  [ -f "$BATS_TEST_TMPDIR/unpackaged/style.css" ]
}

@test "it should package build directory into tarball" {
  run package-archive build tar assets

  [ "$status" -eq 0 ]
  [ -f "$BATS_TEST_TMPDIR/assets.tar" ]
  [[ "$output" =~ .*"::set-output name=filename::assets.tar".* ]]

  mkdir -p "$BATS_TEST_TMPDIR/unpackaged"
  tar -xf "$BATS_TEST_TMPDIR/assets.tar" -C "$BATS_TEST_TMPDIR/unpackaged"
  [ -f "$BATS_TEST_TMPDIR/unpackaged/index.html" ]
  [ -f "$BATS_TEST_TMPDIR/unpackaged/style.css" ]
}


@test "it should package build directory into zip" {
  run package-archive build zip assets

  [ "$status" -eq 0 ]
  [ -f "$BATS_TEST_TMPDIR/assets.zip" ]
  [[ "$output" =~ .*"::set-output name=filename::assets.zip".* ]]

  mkdir -p "$BATS_TEST_TMPDIR/unpackaged"
  unzip "$BATS_TEST_TMPDIR/assets.zip" -d "$BATS_TEST_TMPDIR/unpackaged"
  [ -f "$BATS_TEST_TMPDIR/unpackaged/index.html" ]
  [ -f "$BATS_TEST_TMPDIR/unpackaged/style.css" ]
}
