#!/usr/bin/env bash

function unpack-static-assets() {
  set -eo pipefail

  local file="$1"
  local type="${FILE_TYPE:-}"
  local path="${2:-static-assets}"

  [ -n "$file" ] || {
    echo "[ERROR] File is required" >&2
    return 1
  }
  # shellcheck disable=SC2116,SC2086
  # https://github.com/koalaman/shellcheck/wiki/SC2116
  # https://github.com/koalaman/shellcheck/wiki/SC2086
  # We would like the wildcard to expand here so we get the actual filename
  file="$(builtin echo $file)"

  [ -n "$type" ] || {
    type="$(basename "$file")"
    type="${type#*.}"
  }

  mkdir -p "$path"

  case "$type" in
    tar )
      echo "[DEBUG] Found a tar, unpacking to $path" >&2
      tar -xf "$file" -C "$path"
      ;;
    tgz | tar.gz )
      echo "[DEBUG] Found a gzipped tar, unpacking to $path" >&2
      tar -zxf "$file" -C "$path"
      ;;
    gz )
      local name=''
      name="$(basename "$file" .gz)"
      echo "[DEBUG] Found a gzip, unpacking to $path/$name" >&2
      gunzip -c "$file" > "$path/$name"
      ;;
    zip )
      echo "[DEBUG] Found a zip, unpacking to $path" >&2
      unzip -d "$path" "$file"
      ;;
    * )
      local mime=''
      mime="$(file --mime-type "$file")"
      mime="${mime/"$file": /}"
      if [ "$mime" = inode/directory ]; then
        echo "[DEBUG] Found a directory, copying to $path" >&2
        cp -r "$file/" "$path"
      else
        echo "[ERROR] Unknown file type: $mime" >&2
        return 1
      fi
      ;;
  esac

  echo "::set-output name=path::$path"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  unpack-static-assets "${@:-}"
  exit $?
fi
