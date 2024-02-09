resource "aws_security_group" "rds_sg" {
  name        = "hapi-db-sg"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "open for all ingress on 5432"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.private_sb_cidr

  }

  egress {
    description = "all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "hapi-db-sg"
  }
}
resource "aws_security_group" "eks_node_sg" {
  name        = "hapi-app-node-sg"
  description = "Security group for EKS hapi app"
  vpc_id      = var.vpc_id

  ingress {
    description = "open for all ingress traffic on port 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "hapi-app-node-sg"
  }
}
