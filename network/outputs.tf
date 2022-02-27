output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  value = [
  for subnet in aws_subnet.public: subnet.id
  ]
}

output "private_subnet_ids" {
  value = [
    for subnet in aws_subnet.private: subnet.id
  ]
}

output "db_security_group_id" {
  value = aws_security_group.allow_access_db.id
}

output "beanstalk_security_group_id" {
  value = aws_security_group.beanstalk-default.id
}