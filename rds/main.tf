# minimum rds setup
resource "aws_db_instance" "hapi_db" {
  allocated_storage      = var.storage
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.password
  skip_final_snapshot    = true
  vpc_security_group_ids = var.vpc_sg_ids
}
