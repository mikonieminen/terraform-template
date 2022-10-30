#!/bin/sh
set -eu

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset ASSUME_ROLE

WORKDIR=$(
    cd "$(dirname "$0")"
    pwd -P
)

if [ ! -f "${WORKDIR}/.env" ]; then
    echo "Could not find ${WORKDIR}/.env file to read configs." >&2
    exit 1
fi

help() {
    echo "Tool to get AWS session tokens for managing the infrastructure" >&2
    echo "" >&2
    echo "Usage: $(basename "$0") [options...]" >&2
    echo " -r <role>    Role to acquire. When left out, provides user specific credentials" >&2
    echo "              instead of creadentials bound to an assumed role. Role should be" >&2
    echo "              'infra-admin', 'account-admin' or one defined under the AWS account." >&2
    echo " -p <profile> Override AWS client profile selection" >&2
    echo " -h           Print this help." >&2
    echo "" >&2
    echo "This script helps on setting up environment variables to use 'aws-cli'." >&2
    echo "First it expects that all credentials are stored using KeepassXC and" >&2
    echo "that you have 'keepassxc-cli' installed." >&2
    echo "Then you need to have '.env' file with the following entries:" >&2
    echo "" >&2
    echo "KEEPASSXC_FILE=\"<path to keepassxc file to use>\"" >&2
    echo "KEEPASSXC_ENTRY=\"<keepassxc entry name holding credentials>\"" >&2
    echo "AWS_PROFILE=\"<profile from ~/.aws/config or use default if empty or missing>\"" >&2
    echo "" >&2
    echo "In KeepassXC, the entry needs TOTP configured for the entry and then additional" >&2
    echo "variable defined as 'mfa-device-arn' with value from your AWS account. You can" >&2
    echo "find this value in https://console.aws.amazon.com/iam/home#/security_credentials" >&2
    echo "under 'Multi-factor authentication (MFA)' where you should have at least one" >&2
    echo "item under 'Assigned MFA device'" >&2
    echo "" >&2
    echo "When running this script, it will promt for keepassxc password and finally" >&2
    echo "outputs environment varibles for your new session. You can source these" >&2
    echo "varibles into your environment by wrapping the script output into an eval:" >&2
    echo "'eval \$(./$0)'" >&2
    echo "" >&2
}

# Skip checking .env file as it is not under git
# shellcheck source=/dev/null
. "${WORKDIR}/.env"

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
