#!/usr/bin/env bash

function tag-lambda() {
  set -eo pipefail

  local function_name="${1:-}"
  [ -n "$function_name" ] || {
    echo "[ERROR] Function name not provided" >&2
    return 1
  }

  [ -n "$LAMBDA_TAGS" ] || {
    echo "[DEBUG] No tags provided" >&2
    return 0
  }

  local tags=''
  while IFS= read -r tag_var; do
    # Remove blank space around the string
    tag_var="$(echo "${tag_var?}" | xargs)"
    key="${tag_var%=*}"
    val="${tag_var#*=}"

    [ -n "${tag_var?}" ] || continue

    tags+="$key=$val,"
  done <<<"$LAMBDA_TAGS"
  tags="${tags::-1}" # pop off the last comma

  local lambda_arn=''
  lambda_arn=$(
    aws lambda get-function \
      --function-name "$function_name" \
      --query 'Configuration.FunctionArn' \
      --output text \
      --no-cli-pager
  )

  aws lambda tag-resource \
    --resource "$lambda_arn" \
    --tags "$tags"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  tag-lambda "${@:-}"
  exit $?
fi
