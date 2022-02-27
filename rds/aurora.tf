
resource "random_password" "db_password" {
  length = 8
  special = true
}

resource "aws_db_subnet_group" "default" {
  name       = format("%s-db-subnet-group",var.rds_cluster_name)
  subnet_ids = var.db_subnet_group

}

resource "aws_rds_cluster" "default" {

  apply_immediately       = true
  cluster_identifier      = var.rds_cluster_name
  engine                  = var.db_engine
  engine_version          = var.db_engine_version

  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = var.db_security_group

  database_name           = var.db_name
  master_username         = var.db_user
  master_password         = random_password.db_password.result

  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window

  deletion_protection     = var.db_delete_protection
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 2
  identifier         = format("%s-%s",var.rds_cluster_name,count.index)
  cluster_identifier = aws_rds_cluster.default.id
  instance_class     = var.rds_instance_class
  engine             = aws_rds_cluster.default.engine
  engine_version     = aws_rds_cluster.default.engine_version
}

