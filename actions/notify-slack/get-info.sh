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
    local to_env=''
    if [ -n "${ENVIRONMENT:-}" ]; then
      to_env=" to ${ENVIRONMENT}"
    fi

    MESSAGE="A $TYPE for ${APPLICATION}:${VERSION}${to_env} resulted in ${STATUS}"

    if [ "$STATUS" = started ]; then
      MESSAGE="A $TYPE has been started for $APPLICATION:$VERSION${to_env}"
    fi
  fi
  echo "message=${MESSAGE:-}" >>"$GITHUB_OUTPUT"

  [ -n "$TEMPLATE" ] || TEMPLATE="$GITHUB_ACTION_PATH/message.json.j2"
  echo "template=$TEMPLATE" >>"$GITHUB_OUTPUT"

  TIMESTAMP="$(date +%s)"
  echo "timestamp=$TIMESTAMP" >>"$GITHUB_OUTPUT"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  get-info "${@:-}"
  exit $?
fi
