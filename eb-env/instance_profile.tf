##################################################
## IAM Roles and profiles
##################################################
resource "aws_iam_instance_profile" "beanstalk_service" {
  name = "${local.beanstalk_full_name}-beanstalk-service-user"
  role = aws_iam_role.beanstalk_service.name
}
resource "aws_iam_instance_profile" "beanstalk_ec2" {
  name = "${local.beanstalk_full_name}-beanstalk-ec2-user"
  role = aws_iam_role.beanstalk_ec2.name
}
resource "aws_iam_role" "beanstalk_service" {
  name = "${local.beanstalk_full_name}-beanstalk-service-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticbeanstalk.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "elasticbeanstalk"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role" "beanstalk_ec2" {
  name = "${local.beanstalk_full_name}-beanstalk-ec2-role"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "beanstalk_service" {
  role       = aws_iam_role.beanstalk_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}
resource "aws_iam_role_policy_attachment" "beanstalk_service_health" {
  role       = aws_iam_role.beanstalk_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}
resource "aws_iam_role_policy_attachment" "beanstalk_ec2_web" {
  role       = aws_iam_role.beanstalk_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}