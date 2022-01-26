#!/usr/bin/env bash

function package-archive() {
  set -eo pipefail

  local directory="${1:-build}"
  local type="${2:-tgz}"
  local filename="${3:-}"
  local extension="${EXTENSION:-}"

  [ -d "$directory" ] || {
    echo "[ERROR] Directory not found: $directory" >&2
    return 1
  }
  [ -n "$filename" ] || {
    filename="$(basename "$directory")"
    echo "[DEBUG] Defaulting the filename from directory to $directory" >&2
  }

  case "$type" in
    tar )
      [ -n "$extension" ] || extension=tar

      echo "[INFO ] Packaging up $directory to $filename.$extension into tarball" >&2
      tar -cf "$filename.$extension" -C "$directory" .
      ;;
    tgz )
      [ -n "$extension" ] || extension=tgz

      echo "[INFO ] Packaging up $directory to $filename.$extension into gzipped tarball" >&2
      tar -zcf "$filename.$extension" -C "$directory" .
      ;;
    zip )
      [ -n "$extension" ] || extension=zip

      # Save off the working directory because zip has no change directory option
      local working_directory="$PWD"

      # Enter the build directory and then zip .
      pushd "$directory" >/dev/null || return 3

        ls -al

        echo "[INFO ] Zipping up $directory to $filename.$extension" >&2
        zip -r "$working_directory/$filename.$extension" .

      popd >/dev/null || return 3
      ;;
    * )
      echo "[ERROR] Unknown archive type requested: $type" >&2
      return 2
      ;;
  esac

  echo "::set-output name=filename::$filename.$extension"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  package-archive "${@:-}"
  exit $?
fi
