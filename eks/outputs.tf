
output "cluster_endpoint" {
  value = data.aws_eks_cluster.cluster.endpoint
}

output "aws_eks_cluster_auth" {
  value = data.aws_eks_cluster.cluster.certificate_authority.0.data

}

output "cluster_token" {
  value = data.aws_eks_cluster_auth.cluster.token
}
