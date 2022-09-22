# Project Name

## Table of Contents

- [Project Structure](#project-structure)
- [Setup](#setup)
  - [Installing Git Hooks](#installing-git-hooks)
  - [Initializing Terraform projects](#initializing-terraform-projects)
    - [First time initialization of `aws-account` project](#first-time-initialization-of-aws-account-project)
    - [First time initialization of `infrastructure` project](#first-time-initialization-of-infrastructure-project)
    - [Initialize `aws-account` project by reading an existing state](#initialize-aws-account-project-by-reading-an-existing-state)
    - [Initialize `infrastructure` project by reading an existing state](#initialize-infrastructure-project-by-reading-an-existing-state)
- [Managing Infrastructure with Terraform](#managing-infrastructure-with-terraform)
  - [Configure AWS Cli manually](#configure-aws-cli-manually)
  - [Use get-aws-session-token.sh script](#use-get-aws-session-tokensh-script)
  - [KeePassXC Integration](#keepassxc-integration)

## Project Structure

### Terraform

#### AWS Account

This is a Terraform project containing AWS Account related topics that require higher level privileges to modify.

#### Infrastructure

This is a Terraform project that contains the actual infrastructure that can be managed with basic infrastructure admin permissions.

## Setup

### Installing Git Hooks

Installing these hooks will prevent the user from committing source code, shell scripts, Terraform or Packer files unless they are properly formatted. Install by running:

```sh
make install-git-hooks
```

### Initializing Terraform projects

#### First time initialization of `aws-account` project

This part defines account wide configurations, roles and permissions and also this manages S3 bucket for Terraform state.

1. make sure the `backend` block is commented out in `terraform/aws-account/main.tf`
2. run following commands:

```sh
cd terraform/aws-account
terraform init
terraform apply -target=aws_s3_bucket.terraform_bucket -target=aws_dynamodb_table.terraform_state_lock
# review the plan and answer `yes`
```

3. uncomment `backend` block in `terraform/aws-account/main.tf`
4. run `terraform output terraform_backend_config`
5. get `bucket` `region` and `dynamodb_table` values from previous output and replace in the following and run: `terraform init -backend-config="bucket=<bucket>" -backend-config="region=<region>" -backend-config="dynamodb_table=<dynamodb_table>"`
6. answer `yes` when prompt for replacing pre-existing state while migrating from "local" to newly configured "s3" backend

#### First time initialization of `infrastructure` project

1. move to `aws-account` project: `cd terraform/aws-account`
2. run `terraform output terraform_backend_config`
3. move to `infrastructure` project: `cd ../terraform/infrastructure`
4. from the `terraform_backend_config` output, pick `bucket`, `region` and `dynamodb_table` values, replace in the following command `terraform init -backend-config="bucket=<bucket>" -backend-config="region=<region>" -backend-config="dynamodb_table=<dynamodb_table>"` and execute the command

#### Initialize `aws-account` project by reading an existing state

1. move to `aws-account` project: `cd terraform/aws-account`
2. uncommend, unless already uncommented, `backend` block in `main.tf
3. ask from another user, who has already initialized the project, to provide you the output of `terraform output terraform_backend_config`.
4. from the `terraform_backend_config` output, pick `bucket`, `region` and `dynamodb_table` values, replace in the following command `terraform init -backend-config="bucket=<bucket>" -backend-config="region=<region>" -backend-config="dynamodb_table=<dynamodb_table>"` and execute the command

#### Initialize `infrastructure` project by reading an existing state

1. move to `infrastructure` project: `cd terraform/infrastructure`
2. ask from another user, who has access to `aws-account` project, to provide you the output of `terraform output terraform_backend_config`.
3. from the `terraform_backend_config` output, pick `bucket`, `region` and `dynamodb_table` values, replace in the following command `terraform init -backend-config="bucket=<bucket>" -backend-config="region=<region>" -backend-config="dynamodb_table=<dynamodb_table>"` and execute the command

## Managing Infrastructure with Terraform

### Configure AWS Cli manually

You will need an `Access Key` that you get from [here](https://console.aws.amazon.com/iam/home?region=eu-central-1#/security_credentials) and look under `Access Keys`. If you don't have one, then create new one and store the secret part safely. You will need both `Access key ID` and `Secret access Key` in the next step.

Now, configure your identity:

```sh
aws configure
```

and for `AWS Access Key ID`, pass the `Access key ID` that you got from top menu - `My Security Credentials` page and for `AWS Secret Access Key` pass the `Secret access key`. For `Default region name`, you can give `eu-central-1` unless you prefer something else and the `Default output format` you can leave empty.

Check your current identity (including account ID):

```sh
aws sts get-caller-identity
```

Any command can take `--profile <profile name>` as an argument so that you can have multiple profiles on the same machine:

```sh
aws --profile personal configure
aws --profile personal sts get-caller-identity
```

You will also need your MFA device ID that you get from [here](https://console.aws.amazon.com/iam/home?region=eu-central-1#/security_credentials) and look under `Multi-factor authentication (MFA)` and copy the `arn`. If you don't have a MFA device yet, you need to add one.

Then get a session token and replace `<MFA code>` with the current value from your token

```sh
export MFA_DEVICE_ARN="..."
aws --profile personal sts get-session-token --serial-number "${MFA_DEVICE_ARN}" --token-code <MFA code>
```

Then you should export the following values as environment variables:

```sh
export AWS_ACCESS_KEY_ID="<value of .Credentials.AccessKeyId>"
export AWS_SECRET_ACCESS_KEY="<value of .Credentials.SecretAccessKey>"
export AWS_SESSION_TOKEN="<value of .Credentials.SessionToken>"
```

### Use get-aws-session-token.sh script

This script allows you to setup AWS session so that you can executed AWS cli commands or use Terraform to manage our environment. See the below part about configuring things for KeePassXC as this script fetches your personal credentials from it.

You need to create `.env` file that contains following information:

```env
KEEPASSXC_FILE="<path to KeePassXC file>"
KEEPASSXC_ENTRY="<name/path to entry for account details in your KeePassXC file>"
AWS_PROFILE="<AWS cli profile to use, can be default>"
```

Then run the script to create environment variables that you can evaluate in your terminal:

```sh
./get-aws-session-token.sh
```

or even wrap the call in `eval` so that your environment variables are set correctly:

```sh
eval $(./get-aws-session-token.sh)
```

Also good to read is the [MFA token authentication documentation](https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/)

### KeePassXC Integration

When getting AWS session token, using KeePassXC can be very helpful and you can extract all needed details from command line.

Creating an entry with all details is easier with GUI app:

1. create the entry
2. set URL to `https://123456789012.signin.aws.amazon.com/console`
3. switch to Advanced (left-side panel)
4. add attribute key `mfa-device-arn` and value as describe above for `MFA_DEVICE_ARN`
5. add attribute key `account-id` and set value to `123456789012`
6. select from application mene `Entries` -> `TOTP` -> `Set up TOTP...` and insert secret key
   - the secret key you can only read when creating new Virtual MFA device in
     AWS console, so you might need to replace the existing one unless you have
     saved the value earlier, you can still use the same TOTP key on both:
     KeePassXC and on your mobile phone
7. Save the entry

Now to extract the needed info using command-line tool (requires version 2.6+):

```sh
keepassxc-cli show /path/to/secrets.kdbx "<KeePassXC entry name>" -t -a mfa-device-arn
```

and you should see output like:

```sh
arn:aws:iam::123456789012:mfa/username
123456
```

This you can use together with `get-aws-session-token.sh` script or directly with `aws sts get-session-token` command.

#### Installing keepassxc-cli on Ubuntu

Note: keepassxc-cli has outdated version in official repository on Ubuntu, to install version 2.6+ requires adding PPA:

```sh
sudo add-apt-repository ppa:phoerious/keepassxc
sudo apt update
sudo apt install keepassxc
```
