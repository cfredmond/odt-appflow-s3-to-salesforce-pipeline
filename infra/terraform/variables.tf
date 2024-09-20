variable "environment" {
  description = "The environment for the deployment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "odt"
}

variable "managed_by" {
  description = "Who manages the resources"
  type        = string
  default     = "Terraform"
}

variable "source_bucket_prefix" {
  description = "The prefix for the source S3 bucket"
  type        = string
  default     = "odt-source-dev-data.csv"
}

variable "appflow_service_principal" {
  description = "The service principal for AWS AppFlow"
  type        = string
  default     = "appflow.amazonaws.com"
}