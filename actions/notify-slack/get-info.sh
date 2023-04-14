#!/usr/bin/env bash

function get-info() {
  set -eo pipefail

  if [ -z "${EMOJI:-}" ]; then
    case "${STATUS:-}" in
    success)
      EMOJI=large_green_circle
      ;;
    failure)
      EMOJI=red_circle
      ;;
    started)
      EMOJI=large_blue_circle
      ;;
    *)
      EMOJI=white_circle
      ;;
    esac
  fi
  echo emoji="$EMOJI" >>"$GITHUB_OUTPUT"

  if [ -z "${MESSAGE:-}" ]; then
    MESSAGE="A ${TYPE} for ${APPLICATION}:${VERSION} to ${ENVIRONMENT} resulted in ${STATUS}"

    if [ "$STATUS" = started ]; then
      MESSAGE="A $TYPE has been started for $APPLICATION:$VERSION to $ENVIRONMENT"
    fi
  fi
  echo "message=${MESSAGE:-}" >>"$GITHUB_OUTPUT"

  TIMESTAMP="$(date +%s)"
  echo "timestamp=$TIMESTAMP" >>"$GITHUB_OUTPUT"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  get-info "${@:-}"
  exit $?
fi
