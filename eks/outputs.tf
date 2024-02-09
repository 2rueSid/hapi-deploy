
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "aws_eks_cluster_auth" {
  value = module.eks.cluster_certificate_authority_data
}

output "cluster_token" {
  value = data.aws_eks_cluster_auth.cluster.token
}
