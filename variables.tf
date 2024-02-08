variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}


variable "vpc_version" {
  type    = string
  default = "0.0.1"
}

variable "name" {
  type    = string
  default = "hapi"
}
