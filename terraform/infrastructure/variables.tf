variable "region" {
  type        = string
  description = "Default region where the infrastructure resources should be deployed."
}

variable "deployment_key_name" {
  description = "SSH key to use during deployment"
  type        = string
}
