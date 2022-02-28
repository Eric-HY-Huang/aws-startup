# Fetch available az according to the region specified in provider
data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name = "zone-type"
    values = ["availability-zone"]
  }
}

locals {
  az_names = data.aws_availability_zones.available.names
  public_cidr = cidrsubnet(var.vpc_cidr, 1, 0)
  private_cidr = cidrsubnet(var.vpc_cidr, 1, 1)
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public" {
  for_each                = {for idx, az_name in local.az_names: idx => az_name}
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(local.public_cidr, var.newbits_for_subnet_cidr - 1, each.key)
  availability_zone       = local.az_names[each.key]

  tags = {
    Name = format("public-%s",local.az_names[each.key])
  }
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  for_each                = {for idx, az_name in local.az_names: idx => az_name}
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(local.private_cidr, var.newbits_for_subnet_cidr - 1, each.key)
  availability_zone       = local.az_names[each.key]

  tags = {
    Name = format("private-%s",local.az_names[each.key])
  }
}

resource "aws_internet_gateway" "default" {
    vpc_id = aws_vpc.main.id

    tags = {
      Name = "main"
    }

}









