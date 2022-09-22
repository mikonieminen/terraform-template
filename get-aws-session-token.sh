#!/usr/bin/env bash
set -euo pipefail

# This script helps on setting up environment variables to
# use `aws-cli`.
# First it expects that all credentials are stored using KeepassXC and
# that you have `keepassxc-cli` installed.
# Then you need to have `.env` file with the following entries:
# ```
# KEEPASSXC_FILE="<path to keepassxc file that should be used>"
# KEEPASSXC_ENTRY="<keepassxc entry name holding credentials>"
# AWS_PROFILE="<profile name in ~/.aws/config or if empty or missing, using default>"
# ```
# In KeepassXC, the entry needs TOTP configured for the entry and then additional
# variable defined as `mfa-device-arn` with value from your AWS account.
# You can find this value in https://console.aws.amazon.com/iam/home#/security_credentials
# under *Multi-factor authentication (MFA)* where you should have at least one
# item under *Assigned MFA device*
#
# When running this script, it will promt for keepassxc password and finally
# outputs environment varibles for your new session. You can source these
# varibles into your environment by wrapping the script output into an eval:
# `eval $(./get-aws-session-token.sh)`

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

if [ ! -f ".env" ]; then
    echo "Could not find $(pwd)/.env file to read configs." >&2
    exit 1
fi

# Skip checking .env file as it is not under git
# shellcheck disable=SC1091
source .env

CREDS="$(keepassxc-cli show "$KEEPASSXC_FILE" "$KEEPASSXC_ENTRY" -t -a mfa-device-arn)"
MFA_DEVICE_ARN="$(echo "$CREDS" | head -n 1)"
TOTP="$(echo "$CREDS" | tail -n 1)"

AWS_PROFILE="${AWS_PROFILE:-""}"

if [ -z "$AWS_PROFILE" ]; then
    aws sts get-session-token --serial-number "$MFA_DEVICE_ARN" --token "$TOTP" | jq --raw-output '. | " export AWS_ACCESS_KEY_ID=\"\(.Credentials.AccessKeyId)\"\n export AWS_SECRET_ACCESS_KEY=\"\(.Credentials.SecretAccessKey)\"\n export AWS_SESSION_TOKEN=\"\(.Credentials.SessionToken)\"\n"'
else
    aws sts get-session-token --profile "$AWS_PROFILE" --serial-number "$MFA_DEVICE_ARN" --token "$TOTP" | jq --raw-output '. | " export AWS_ACCESS_KEY_ID=\"\(.Credentials.AccessKeyId)\"\n export AWS_SECRET_ACCESS_KEY=\"\(.Credentials.SecretAccessKey)\"\n export AWS_SESSION_TOKEN=\"\(.Credentials.SessionToken)\"\n"'
fi
