terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

variable "zone" {
  type = object({
    name = string
  })
}

variable "validation_record_fqdns" {
  type = list(string)
}

# resource "aws_acm_certificate" "auth" {
#   domain_name       = "auth.${var.zone.name}"
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_acm_certificate_validation" "auth" {
#   certificate_arn         = aws_acm_certificate.auth.arn
#   validation_record_fqdns = var.validation_record_fqdns
# }

# output "aws_acm_certificate" {
#   value = aws_acm_certificate.auth
# }

# output "aws_acm_certificate_validation" {
#   value = aws_acm_certificate_validation.auth
# }
