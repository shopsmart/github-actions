#!/usr/bin/env bash

function get-info() {
  set -eo pipefail

  if [ -z "${EMOJI:-}" ]; then

    # MESSAGE="A $TYPE for $APPLICATION:$VERSION to $ENVIRONMENT resulted in $STATUS"
    case "${STATUS:-}" in
    success)
      EMOJI=large_green_circle
      ;;
    failure)
      EMOJI=red_circle
      ;;
    started)
      EMOJI=large_blue_circle
      # MESSAGE="A $TYPE has been started for $APPLICATION:$VERSION to $ENVIRONMENT"
      ;;
    *)
      EMOJI=white_circle
      ;;
    esac

  fi
  echo emoji="$EMOJI" >>"$GITHUB_OUTPUT"
  TIMESTAMP="$(date +%s)"
  MESSAGE="A ${TYPE:-}for ${APPLICATION:-}:${VERSION:-} to ${ENVIRONMENT:-} resulted in ${STATUS:-}"

  if [ "${STATUS:-}" = "success" ]; then
    echo "status=success" >>"$GITHUB_OUTPUT"
    echo "message=$MESSAGE" >>"$GITHUB_OUTPUT"
  else
    echo "status=failure" >>"$GITHUB_OUTPUT"
    echo "message=$MESSAGE" >>"$GITHUB_OUTPUT"
  fi

  echo "timestamp=$TIMESTAMP" >>"$GITHUB_OUTPUT"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  get-info "${@:-}"
  exit $?
fi
