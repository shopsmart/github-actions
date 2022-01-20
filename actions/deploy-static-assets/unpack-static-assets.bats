#!/usr/bin/env bats

load unpack-static-assets.sh

function setup() {
  create_archives

  export TAR_FILE="$BATS_TEST_TMPDIR/archive.tar"
  export TAR_GZ_FILE="$BATS_TEST_TMPDIR/archive.tar.gz"
  export TGZ_FILE="$BATS_TEST_TMPDIR/archive.tgz"
  export ZIP_FILE="$BATS_TEST_TMPDIR/archive.zip"
  export TARGZIP_FILE="$BATS_TEST_TMPDIR/archive.targzip"
  export ARCHIVE_DIRECTORY="$BATS_TEST_TMPDIR/archive"
  export INDEX_FILE="$BATS_TEST_TMPDIR/archive/public/index.html"

  export DESTINATION="$BATS_TEST_TMPDIR/static-assets"

  pushd "$BATS_TEST_TMPDIR" >/dev/null
}

function teardown() {
  popd >/dev/null
}

function create_archives() {
  pushd "$BATS_TEST_TMPDIR" >/dev/null
    mkdir -p archive/public

    echo "<html><head></head><body>Hello world</body></html>" > archive/public/index.html

    tar -cf archive.tar -C archive/ .
    tar -zcf archive.tar.gz -C archive/ .
    tar -zcf archive.tgz -C archive/ .
    tar -zcf archive.targzip -C archive/ .

    pushd archive >/dev/null
      zip -r ../archive.zip .
    popd >/dev/null
  popd >/dev/null
}

@test "it should unpack the .tar" {
  run unpack-static-assets "$TAR_FILE" "$DESTINATION"

  [ "$status" -eq 0 ]
  [ -d "$DESTINATION/public" ]
  [ -f "$DESTINATION/public/index.html" ]
}

@test "it should unpack the .tar.gz" {
  run unpack-static-assets "$TAR_GZ_FILE" "$DESTINATION"

  [ "$status" -eq 0 ]
  [ -d "$DESTINATION/public" ]
  [ -f "$DESTINATION/public/index.html" ]
}

@test "it should unpack the .tgz" {
  run unpack-static-assets "$TGZ_FILE" "$DESTINATION"

  [ "$status" -eq 0 ]
  [ -d "$DESTINATION/public" ]
  [ -f "$DESTINATION/public/index.html" ]
}

@test "it should unpack the .zip" {
  run unpack-static-assets "$ZIP_FILE" "$DESTINATION"
  echo "$output"

  [ "$status" -eq 0 ]
  [ -d "$DESTINATION/public" ]
  [ -f "$DESTINATION/public/index.html" ]
}

@test "it should unpack the .tgzip as .tgz" {
  export FILE_TYPE=tgz

  run unpack-static-assets "$TARGZIP_FILE" "$DESTINATION"

  [ "$status" -eq 0 ]
  [ -d "$DESTINATION/public" ]
  [ -f "$DESTINATION/public/index.html" ]
}

@test "it should copy the directory to the path" {
  run unpack-static-assets "$ARCHIVE_DIRECTORY" "$DESTINATION"

  [ "$status" -eq 0 ]
  [ -d "$DESTINATION/public" ]
  [ -f "$DESTINATION/public/index.html" ]
}

@test "it should error out if it cannot determine the type" {
  run unpack-static-assets "$INDEX_FILE" "$DESTINATION"

  [ "$status" -ne 0 ]
}
