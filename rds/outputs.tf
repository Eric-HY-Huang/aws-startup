output "rds_host" {
  value = aws_rds_cluster.default.endpoint
}

output "db_port" {
  value = aws_rds_cluster.default.port
}

output "db_name" {
  value = aws_rds_cluster.default.database_name
}


output "db_user" {
  value = aws_rds_cluster.default.master_username
}

output "db_password" {
  value = aws_rds_cluster.default.master_password
}