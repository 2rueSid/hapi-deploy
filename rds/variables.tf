variable "storage" {
  type = number
}
variable "engine" {
  type = string
}
variable "engine_version" {
  type = string
}
variable "instance_class" {
  type = string
}
variable "db_name" {
  type = string
}
variable "db_username" {
  type = string
}
variable "password" {
  type = string
}
variable "vpc_sg_ids" {
  type = list(string)
}
