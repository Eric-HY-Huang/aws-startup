locals {
  beanstalk_full_name = format("%s-%s",var.service_name,var.env)
}

data "aws_elastic_beanstalk_solution_stack" "php_platform" {
  most_recent = true
  name_regex = "^64bit Amazon Linux (.*) running PHP (.*)$"
}

resource "aws_elastic_beanstalk_application" "web" {
  name        = local.beanstalk_full_name
  description = "for demo"
}

resource "aws_elastic_beanstalk_environment" "web_env" {
  name                = format("%s-env",)
  application         = aws_elastic_beanstalk_application.web.name
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.php_platform.name

  # https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html
  # Configure your environment's EC2 instances.
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "${var.instance_type}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeType"
    value     = "${var.instance_volume_type}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeSize"
    value     = "${var.instance_volume_size}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeIOPS"
    value     = "${var.instance_volume_iops}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "${var.ssh_key_name}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = "${var.security_groups}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${aws_iam_instance_profile.beanstalk_ec2.name}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "${aws_iam_role.beanstalk_service.name}"
  }

  # Configure your environment to launch resources in a custom VPC
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${var.vpc_id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${var.vpc_subnets}"
  }
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:ec2:vpc" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "ELBSubnets" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.elb_subnets : var.environmentType}"
  }

  # Configure your environment's Auto Scaling group.
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "${var.min_instance}"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "${var.max_instance}"
  }

  # Configure scaling triggers for your environment's Auto Scaling group.
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:autoscaling:trigger" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "BreachDuration" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.as_breach_duration : var.environmentType}"
  }
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:autoscaling:trigger" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "LowerBreachScaleIncrement" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.as_lower_breach_scale_increment : var.environmentType}"
  }
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:autoscaling:trigger" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "LowerThreshold" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.as_lower_threshold : var.environmentType}"
  }
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:autoscaling:trigger" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "MeasureName" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.as_measure_name : var.environmentType}"
  }
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:autoscaling:trigger" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "Period" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.as_period : var.environmentType}"
  }
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:autoscaling:trigger" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "Statistic" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.as_statistic : var.environmentType}"
  }
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:autoscaling:trigger" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "Unit" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.as_unit : var.environmentType}"
  }
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:autoscaling:trigger" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "UpperBreachScaleIncrement" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.as_upper_breachs_scale_increment : var.environmentType}"
  }
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:autoscaling:trigger" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "UpperThreshold" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.as_upper_threshold : var.environmentType}"
  }

  # Configure rolling deployments for your application code.
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "${var.deployment_policy}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "IgnoreHealthCheck"
    value     = "${var.ignore_healthcheck}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "${var.healthreporting}"
  }

  # Configure your environment's architecture and service role.
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "${var.environmentType}"
  }

  # Configure the default listener (port 80) on a classic load balancer.
  setting {
    namespace = var.environmentType == "LoadBalanced" ? "aws:elb:listener:80" : "aws:elasticbeanstalk:environment"
    name      = var.environmentType == "LoadBalanced" ? "InstancePort" : "EnvironmentType"
    value     = var.environmentType == "LoadBalanced" ? var.port : var.environmentType
  }
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:elb:listener:80" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "ListenerEnabled" : "EnvironmentType"}"
    value     = var.environmentType == "LoadBalanced" ? var.enable_http : var.environmentType
  }

  # Configure additional listeners on a classic load balancer.
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:elb:listener:443" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "ListenerProtocol" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? "HTTPS" : var.environmentType}"
  }
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:elb:listener:443" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "InstancePort" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.port : var.environmentType}"
  }
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:elb:listener:443" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "SSLCertificateId" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.ssl_certificate_id : var.environmentType}"
  }
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:elb:listener:443" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "ListenerEnabled" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.enable_https : var.environmentType}"
  }

  # Modify the default stickiness and global load balancer policies for a classic load balancer.
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:elb:policies" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "ConnectionSettingIdleTimeout" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.elb_connection_timeout : var.environmentType}"
  }

  # Configure a health check path for your application. (ELB Healthcheck)
  setting {
    namespace = "aws:elasticbeanstalk:application"
    name      = "Application Healthcheck URL"
    value     = "${var.healthcheck_url}"
  }

  # Configure ELB Healthcheck
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:elb:healthcheck" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "HealthyThreshold" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.healthcheck_healthy_threshold : var.environmentType}"
  }
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:elb:healthcheck" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "UnhealthyThreshold" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.healthcheck_unhealthy_threshold : var.environmentType}"
  }
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:elb:healthcheck" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "Interval" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.healthcheck_interval : var.environmentType}"
  }
  setting {
    namespace = "${var.environmentType == "LoadBalanced" ? "aws:elb:healthcheck" : "aws:elasticbeanstalk:environment"}"
    name      = "${var.environmentType == "LoadBalanced" ? "Timeout" : "EnvironmentType"}"
    value     = "${var.environmentType == "LoadBalanced" ? var.healthcheck_timeout : var.environmentType}"
  }

  # PHP Platform Options
  # http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-specific.html#command-options-php
  setting {
    namespace = "aws:elasticbeanstalk:container:php:phpini"
    name      = "document_root"
    value     = "${var.document_root}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:container:php:phpini"
    name      = "memory_limit"
    value     = "${var.memory_limit}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:container:php:phpini"
    name      = "zlib.output_compression"
    value     = "${var.zlib_php_compression}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:container:php:phpini"
    name      = "allow_url_fopen"
    value     = "${var.allow_url_fopen}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:container:php:phpini"
    name      = "display_errors"
    value     = "${var.display_errors}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:container:php:phpini"
    name      = "max_execution_time"
    value     = "${var.max_execution_time}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:container:php:phpini"
    name      = "composer_options"
    value     = "${var.composer_options}"
  }

}