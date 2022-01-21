#!/usr/bin/env bats

load unpack-archive.sh

function setup() {
  create_archives

  export TAR_FILE="$BATS_TEST_TMPDIR/archive.tar"
  export TAR_GZ_FILE="$BATS_TEST_TMPDIR/archive.tar.gz"
  export TGZ_FILE="$BATS_TEST_TMPDIR/archive.tgz"
  export ZIP_FILE="$BATS_TEST_TMPDIR/archive.zip"
  export ARCHIVE_DIRECTORY="$BATS_TEST_TMPDIR/archive"
  export INDEX_FILE="$BATS_TEST_TMPDIR/archive/public/index.html"

  export WILDCARD_FILE="$BATS_TEST_TMPDIR/archive*.gz"

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
    echo "head p { color: black; }" > archive/public/style.css

    tar -cf archive.tar -C archive/ .
    tar -zcf archive.tar.gz -C archive/ .
    tar -zcf archive.tgz -C archive/ .

    pushd archive >/dev/null
      zip -r ../archive.zip .
    popd >/dev/null
  popd >/dev/null
}

@test "it should unpack the .tar" {
  run unpack-archive "$TAR_FILE" "$DESTINATION"

  [ "$status" -eq 0 ]
  [ -d "$DESTINATION/public" ]
  [ -f "$DESTINATION/public/index.html" ]
  [ -f "$DESTINATION/public/style.css" ]
}

@test "it should unpack the .tar.gz" {
  run unpack-archive "$TAR_GZ_FILE" "$DESTINATION"

  [ "$status" -eq 0 ]
  [ -d "$DESTINATION/public" ]
  [ -f "$DESTINATION/public/index.html" ]
  [ -f "$DESTINATION/public/style.css" ]
}

@test "it should unpack the .tgz" {
  run unpack-archive "$TGZ_FILE" "$DESTINATION"

  [ "$status" -eq 0 ]
  [ -d "$DESTINATION/public" ]
  [ -f "$DESTINATION/public/index.html" ]
  [ -f "$DESTINATION/public/style.css" ]
}

@test "it should unpack the .zip" {
  run unpack-archive "$ZIP_FILE" "$DESTINATION"
  echo "$output"

  [ "$status" -eq 0 ]
  [ -d "$DESTINATION/public" ]
  [ -f "$DESTINATION/public/index.html" ]
  [ -f "$DESTINATION/public/style.css" ]
}

@test "it should copy the directory to the path" {
  run unpack-archive "$ARCHIVE_DIRECTORY" "$DESTINATION"

  [ "$status" -eq 0 ]
  [ -d "$DESTINATION/public" ]
  [ -f "$DESTINATION/public/index.html" ]
  [ -f "$DESTINATION/public/style.css" ]
}

@test "it should error out if it cannot determine the type" {
  run unpack-archive "$INDEX_FILE" "$DESTINATION"

  [ "$status" -ne 0 ]
}

@test "it should expand the wildcard" {
  run unpack-archive "$WILDCARD_FILE" "$DESTINATION"

  [ "$status" -eq 0 ]
  [ -d "$DESTINATION/public" ]
  [ -f "$DESTINATION/public/index.html" ]
  [ -f "$DESTINATION/public/style.css" ]
}
