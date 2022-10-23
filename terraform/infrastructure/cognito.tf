# This file contains example Cognito User Pool

# resource "aws_cognito_user_pool" "main" {
#   name = data.aws_route53_zone.root.name

#   username_attributes      = ["email"]
#   auto_verified_attributes = ["email"]

#   sms_authentication_message = "Your verification code is {####}. "

#   mfa_configuration = "OPTIONAL"

#   password_policy {
#     minimum_length                   = 8
#     require_lowercase                = true
#     require_numbers                  = true
#     require_symbols                  = true
#     require_uppercase                = true
#     temporary_password_validity_days = 7
#   }

#   email_configuration {
#     email_sending_account = "COGNITO_DEFAULT"
#   }

#   account_recovery_setting {
#     recovery_mechanism {
#       name     = "verified_email"
#       priority = 1
#     }
#   }

#   schema {
#     attribute_data_type      = "String"
#     developer_only_attribute = false
#     mutable                  = true
#     name                     = "email"
#     required                 = true

#     string_attribute_constraints {
#       max_length = "2048"
#       min_length = "0"
#     }
#   }

#   software_token_mfa_configuration {
#     enabled = true
#   }

#   username_configuration {
#     case_sensitive = false
#   }
# }

# resource "aws_cognito_user_pool_domain" "main" {
#   domain          = module.cognito_certs.aws_acm_certificate.domain_name
#   user_pool_id    = aws_cognito_user_pool.main.id
#   certificate_arn = module.cognito_certs.aws_acm_certificate.arn
#   depends_on = [
#     aws_route53_record.root,
#     module.cognito_certs.aws_acm_certificate_validation
#   ]
# }

# resource "aws_cognito_user_pool_client" "web" {
#   name         = "web"
#   user_pool_id = aws_cognito_user_pool.main.id

#   access_token_validity = 60
#   id_token_validity     = 60

#   token_validity_units {
#     access_token  = "minutes"
#     id_token      = "minutes"
#     refresh_token = "days"
#   }

#   allowed_oauth_flows = ["code"]

#   supported_identity_providers = ["COGNITO"]

#   allowed_oauth_flows_user_pool_client = true

#   generate_secret = true

#   callback_urls = [
#     "https://${aws_acm_certificate.blocks.domain_name}/oauth2/idpresponse"
#   ]

#   allowed_oauth_scopes = [
#     "email",
#     "openid",
#     "profile",
#   ]

#   explicit_auth_flows = [
#     "ALLOW_CUSTOM_AUTH",
#     "ALLOW_REFRESH_TOKEN_AUTH",
#     "ALLOW_USER_PASSWORD_AUTH",
#     "ALLOW_USER_SRP_AUTH",
#   ]

#   read_attributes = [
#     "address",
#     "birthdate",
#     "email",
#     "email_verified",
#     "family_name",
#     "gender",
#     "given_name",
#     "locale",
#     "middle_name",
#     "name",
#     "nickname",
#     "phone_number",
#     "phone_number_verified",
#     "picture",
#     "preferred_username",
#     "profile",
#     "updated_at",
#     "website",
#     "zoneinfo",
#   ]

#   write_attributes = [
#     "address",
#     "birthdate",
#     "email",
#     "family_name",
#     "gender",
#     "given_name",
#     "locale",
#     "middle_name",
#     "name",
#     "nickname",
#     "phone_number",
#     "picture",
#     "preferred_username",
#     "profile",
#     "updated_at",
#     "website",
#     "zoneinfo",
#   ]
# }

# resource "aws_cognito_user_pool_client" "api" {
#   name         = "api"
#   user_pool_id = aws_cognito_user_pool.main.id

#   access_token_validity = 60
#   id_token_validity     = 60

#   token_validity_units {
#     access_token  = "minutes"
#     id_token      = "minutes"
#     refresh_token = "days"
#   }

#   supported_identity_providers = ["COGNITO"]

#   explicit_auth_flows = [
#     "ALLOW_CUSTOM_AUTH",
#     "ALLOW_USER_PASSWORD_AUTH",
#     "ALLOW_USER_SRP_AUTH",
#     "ALLOW_REFRESH_TOKEN_AUTH"
#   ]
# }
