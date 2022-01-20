#!/usr/bin/env bash

function static-assets-info() {
  set -eo pipefail

  # If AWS credentials are provided, we should configure AWS credentials
  local configure_aws_credentials="false"
  [ -z "$AWS_ACCESS_KEY_ID$AWS_SECRET_ACCESS_KEY" ] || {
    configure_aws_credentials="true"
    if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
      echo "[ERROR] Either access key id or secret access key has not been provided" >&2
      exit 1
    fi
  }

  echo "::set-output name=configure-aws-credentials::$configure_aws_credentials"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -u

  static-assets-info "${@:-}"
  exit $?
fi
