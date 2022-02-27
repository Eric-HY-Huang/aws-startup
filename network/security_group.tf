resource "aws_security_group" "allow_access_db" {
  name        = "allow_db_connection"
  description = "Allow inbound traffic from public subnet to db"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "DB connection  from pub subnet"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = [for subnet in aws_subnet.public: subnet.cidr_block]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db_connection"
  }
}

resource "aws_security_group" "beanstalk-default" {
  name        = "beans_talk_default"
  description = "default sg for eb"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "allow https request"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }
  ingress {
    description      = "allow http request"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db_connection"
  }
}