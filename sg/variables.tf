variable "private_sb_cidr" {
  description = "private subnets cidr block"
  type        = list(string)
}

variable "vpc_id" {
  description = "vpc id"
  type        = string
}
variable "rds_vpc_id" {
  type = string
}
