#!/usr/bin/env bash
set -euo pipefail

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset ASSUME_ROLE

if [ ! -f ".env" ]; then
    echo "Could not find $(pwd)/.env file to read configs." >&2
    exit 1
fi

help() {
    echo "Get AWS session tokens for managing the infrastructure" >&2
    echo
    echo "This script helps on setting up environment variables to use 'aws-cli'."
    echo "First it expects that all credentials are stored using KeepassXC and"
    echo "that you have 'keepassxc-cli' installed."
    echo "Then you need to have '.env' file with the following entries:"
    echo
    echo "KEEPASSXC_FILE=\"<path to keepassxc file that should be used>\""
    echo "KEEPASSXC_ENTRY=\"<keepassxc entry name holding credentials>\""
    echo "AWS_PROFILE=\"<profile name in ~/.aws/config or if empty or missing, using default>\""
    echo
    echo "In KeepassXC, the entry needs TOTP configured for the entry and then additional"
    echo "variable defined as 'mfa-device-arn' with value from your AWS account."
    echo "You can find this value in https://console.aws.amazon.com/iam/home#/security_credentials"
    echo "under 'Multi-factor authentication (MFA)' where you should have at least one"
    echo "item under 'Assigned MFA device'"
    echo
    echo "When running this script, it will promt for keepassxc password and finally"
    echo "outputs environment varibles for your new session. You can source these"
    echo "varibles into your environment by wrapping the script output into an eval:"
    echo "'eval \$(./get-aws-session-token.sh)'"
    echo
    echo
    echo "Syntax: $0 [-p|r|h]"
    echo "options:"
    echo "r     Role to acquire. When left out, provides user specific redentials instead"
    echo "      of creadentials bound to an assumed role."
    echo "p     Override profile selection"
    echo "h     Print this help."
    echo
}

# Skip checking .env file as it is not under git
# shellcheck disable=SC1091
source .env

AWS_PROFILE="${AWS_PROFILE:-""}"
AWS_ROLE="${AWS_ROLE:-""}"

while getopts p:r:h OPT; do
    case "$OPT" in
        p)
            AWS_PROFILE="${OPTARG}"
            ;;
        r)
            AWS_ROLE="${OPTARG}"
            ;;

        h)
            help
            exit 1
            ;;
        ?)
            help
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1)) # remove parsed options and args from $@ list

CREDS="$(keepassxc-cli show "$KEEPASSXC_FILE" "$KEEPASSXC_ENTRY" -t -a mfa-device-arn)"
MFA_DEVICE_ARN="$(echo "$CREDS" | head -n 1)"
TOTP="$(echo "$CREDS" | tail -n 1)"

if [ -z "$AWS_PROFILE" ]; then
    eval "$(aws sts get-session-token --serial-number "$MFA_DEVICE_ARN" --token "$TOTP" | jq --raw-output '. | "AWS_ACCESS_KEY_ID=\"\(.Credentials.AccessKeyId)\"\nAWS_SECRET_ACCESS_KEY=\"\(.Credentials.SecretAccessKey)\"\nAWS_SESSION_TOKEN=\"\(.Credentials.SessionToken)\"\n"')"
else
    eval "$(aws sts get-session-token --profile "$AWS_PROFILE" --serial-number "$MFA_DEVICE_ARN" --token "$TOTP" | jq --raw-output '. | "AWS_ACCESS_KEY_ID=\"\(.Credentials.AccessKeyId)\"\nAWS_SECRET_ACCESS_KEY=\"\(.Credentials.SecretAccessKey)\"\nAWS_SESSION_TOKEN=\"\(.Credentials.SessionToken)\"\n"')"
fi

case "$AWS_ROLE" in
    "infra-admin")
        ASSUME_ROLE="InfraAdmin"
        ;;
    "account-admin")
        ASSUME_ROLE="AccountAdmin"
        ;;
    *)
        ASSUME_ROLE="$AWS_ROLE"
        ;;
esac

if [ -z "$ASSUME_ROLE" ]; then
    echo " export AWS_ACCESS_KEY_ID=\"$AWS_ACCESS_KEY_ID\""
    echo " export AWS_SECRET_ACCESS_KEY=\"$AWS_SECRET_ACCESS_KEY\""
    echo " export AWS_SESSION_TOKEN=\"$AWS_SESSION_TOKEN\""
else
    export AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY
    export AWS_SESSION_TOKEN

    AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query="Account" --output="text")"

    aws sts assume-role --role-arn "arn:aws:iam::$AWS_ACCOUNT_ID:role/$ASSUME_ROLE" --role-session-name "${ASSUME_ROLE}Session" | jq --raw-output '. | " export AWS_ACCESS_KEY_ID=\"\(.Credentials.AccessKeyId)\"\n export AWS_SECRET_ACCESS_KEY=\"\(.Credentials.SecretAccessKey)\"\n export AWS_SESSION_TOKEN=\"\(.Credentials.SessionToken)\"\n"'
fi
