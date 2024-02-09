output "private_subnets_cidr_blocks" {
  description = "private_subnets_cidr_blocks"
  value       = module.vpc.private_subnets_cidr_blocks
}
output "vpc_id" {
  description = "vpc id"
  value       = module.vpc.vpc_id

}
output "intra_subnets" {
  description = "intra_subnets"
  value       = module.vpc.intra_subnets

}
output "private_subnets" {
  description = "private_subnets"
  value       = module.vpc.private_subnets
}

output "default_vpc_id" {
  description = "default vpc id"
  value       = aws_default_vpc.default.id
}
