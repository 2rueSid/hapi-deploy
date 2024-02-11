variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "db_name" {
  description = "database name"
  type        = string
}
variable "db_username" {
  description = "database username"
  type        = string
}

variable "password" {
  description = "database password"
  type        = string
}
