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
  db_security_group = [module.network.db_security_group_id]

  db_name           = "demo"
  db_user           = "user"
  # for demo
  db_delete_protection = false
  backup_retention_period = 1
  preferred_backup_window = null
}


module "app" {
  source = "./eb-env"
  # Application settings
  env = "test"
  service_name = "php-demo"

  # Network Setting
  vpc_id      = module.network.vpc_id
  vpc_subnets = join(", ", module.network.public_subnet_ids)
  elb_subnets = join(", ", module.network.public_subnet_ids)
  security_groups = module.network.beanstalk_security_group_id

  # PHP settings
  php_version = "8.0"
  document_root = "/public"
  memory_limit = "512M"
  zlib_php_compression = "Off"
  allow_url_fopen = "On"
  display_errors = "On"
  max_execution_time = "60"
  composer_options = ""

  # Instance settings
  instance_type = "t2.micro"
  min_instance = "2"
  max_instance = "4"

  # ELB
  enable_https = "false" # If true,  ssl_certificate is required, skip for demo

  # DB configuration
  rds_db_name = module.db.db_name
  rds_hostname = module.db.rds_host
  rds_port = module.db.db_port

  rds_username = module.db.db_user
  rds_password = module.db.db_password # insecure to use tf to pass credential, only for demo
}
