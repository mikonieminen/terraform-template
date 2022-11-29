variable "project_name" {
  type        = string
  description = "Project name to prefix or scope resources between multiple deployments based on this template."
}

variable "region" {
  type        = string
  description = "Region where the infrastructure's account side resources should be deployed."
  default     = "eu-central-1"
}

variable "terraform_backend_s3_bucket_name" {
  type        = string
  description = "S3 bucket name that should be used for Terraform backend."
  default     = ""
}
