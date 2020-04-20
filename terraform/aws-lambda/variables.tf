
variable "aws_region" {
  type        = string
  description = "The AWS region to deploy to"
  default     = "eu-central-1"
}

variable "function_name" {
  type        = string
  description = "The name of the service function to be deployed"
  default     = "randomize"
}

variable "tags" {
  type        = map
  description = "Default tags to apply to all resources"
  default = {
    application = "randomize"
    author      = "Sven Hennessen"
  }
}

variable "environment" {
  type        = string
  description = "The environment to deploy the template to"
  default     = "dev"
}


