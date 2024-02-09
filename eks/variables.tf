variable "vpc_id" {
  type = string
}

variable "intra_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "sg_ids" {
  type = list(string)
}
