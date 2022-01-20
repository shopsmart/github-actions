#!/usr/bin/env bash

function unpack-archive() {
  set -eo pipefail

  local file="$1"
  local destination="${2:-unpacked}"

  [ -n "$file" ] || {
    echo "[ERROR] File is required" >&2
    return 1
  }
  [ "$file" = "${file#*\*}" ] || {
    echo "[DEBUG] Found a wildcard file" >&2
    local pre_wildcard="${file%\**}"
    local post_wildcard="${file#*\*}"
    file="$(builtin echo "$pre_wildcard"*"$post_wildcard")"
    echo "[DEBUG] Expanded '$pre_wildcard*$post_wildcard' to $file" >&2
  }

  local mime=''
  mime="$(file --mime-type "$file")"
  mime="${mime/"$file": /}"

  mkdir -p "$destination"

  echo "[DEBUG] Unpacking $mime file $file to $destination" >&2
  case "$mime" in
    application/x-tar )
      echo "[DEBUG] Found a tar, unpacking to $destination" >&2
      tar -xf "$file" -C "$destination"
      ;;
    application/gzip )
      if [[ "$file" =~ .*\.t(ar\.)?gz ]]; then
        echo "[DEBUG] Found a gzipped tar, unpacking to $destination" >&2
        tar -zxf "$file" -C "$destination"
      else
        echo "[DEBUG] Found a gzip, unpacking to $destination" >&2
        cp "$file" "$destination"
        file="$destination/$(basename "$file")"
        gunzip "$file"
      fi
      ;;
    application/zip )
      echo "[DEBUG] Found a zip, unpacking to $destination" >&2
      unzip -d "$destination" "$file"
      ;;
    inode/directory )
      echo "[DEBUG] Found a directory, copying to $destination" >&2
      cp -r "$file/" "$destination"
      ;;
    * )
      echo "[ERROR] Unknown file type: $mime" >&2
      return 1
      ;;
  esac

  echo "::set-output name=destination::$destination"
  echo "::set-output name=mime-type::$mime"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  unpack-archive "${@:-}"
  exit $?
fi
