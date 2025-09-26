#!/usr/bin/env bash

# @see https://mathio28.medium.com/squeezing-disk-space-from-github-actions-runners-an-engineers-guide-d5fbe4443692

DIRECTORIES=(
  # Java (JDKs)
  java="/usr/lib/jvm"
  # .NET SDKs
  dotnet="/usr/share/dotnet"
  # Swift toolchain
  swift="/usr/share/swift"
  # Haskell (GHC)
  ghcup="/usr/local/.ghcup"
  # Julia
  julia="/usr/local/julia*"
  # Android SDKs
  android="/usr/local/lib/android"
  # Chromium
  chromium="/usr/local/share/chromium"
  # Microsoft/Edge
  microsoft="/opt/microsoft"
  # Google Chrome
  google="/opt/google"
  # Azure CLI
  azure="/opt/az"
  # PowerShell
  powershell="/usr/local/share/powershell"
)

function cleanup() {
  local skip=("$@")

  for dir in "${DIRECTORIES[@]}"; do
    local key="${dir%%=*}"
    dir="${dir##*=}"
    local skip_dir=false
    for s in "${skip[@]}"; do
      if [ "$key" = "$s" ]; then
        skip_dir=true
        break
      fi
    done
    if [ "$skip_dir" = false ]; then
      echo "Removing $dir..."
      sudo rm -rf "$dir"
    else
      echo "Skipping $dir..."
    fi
  done
}

if [ "$0" = "${BASH_SOURCE[0]}" ]; then
  set -eo pipefail
  cleanup "${@:-}"
  exit $?
fi
