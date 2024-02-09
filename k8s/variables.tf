variable "db_host" {
  description = "db host"
  type        = string
}

variable "db_username" {
  description = "database username"
  type        = string
}

variable "db_port" {
  description = "database port"
  type        = string
  default     = "5432"
}

variable "db_password" {
  description = "database password"
  type        = string
}

variable "db_name" {
  description = "database name"
  type        = string
}

variable "db_engine" {
  description = "database engine"
  type        = string
  default     = "postgresql"
}
