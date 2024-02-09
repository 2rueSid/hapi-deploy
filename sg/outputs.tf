output "rds_sg_id" {
  description = "rds sg id"
  value       = aws_security_group.rds_sg.id
}
output "eks_sg_id" {
  description = "eks sg id"
  value       = aws_security_group.eks_node_sg.id
}
