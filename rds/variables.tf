variable "db_subnet_group" {
  type = list(string)
}

variable "rds_cluster_name" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_engine" {}

variable "db_engine_version" {}

variable "backup_retention_period" {
  default = 5
}

variable "preferred_backup_window" {
  default = "03:00-05:00"
}

variable "db_delete_protection" {default = true}

variable "rds_instance_class" {default = "db.t2.small"}