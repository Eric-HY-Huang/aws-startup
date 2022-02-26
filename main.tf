module "network" {
  source = "./network"
  vpc_name = "aws-demo"
}

module "db" {
  source = "./rds"
  rds_cluster_name  = "aws-demo"
  db_engine         = "aurora-mysql"
  db_engine_version = "5.7.mysql_aurora.2.03.2"

  db_subnet_group = module.network.private_subnet_ids

  db_name           = "demo-only"
  db_user           = "demo-user"

}