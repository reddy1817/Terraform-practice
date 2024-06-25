locals {
  defaults = {
    Name = "RD-vpc"
    Env  = "Dev"
  }
  public = {
    Name      = "RD-vpc-public"
    Env       = "Dev"
    Purpose   = "App Layer"
    Placement = "public"
  }
  private = {
    Name      = "RD-vpc-private"
    Env       = "Dev"
    Purpose   = "App Layer"
    Placement = "private"
  }
}

resource "aws_vpc" "RD-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags                 = local.defaults

}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.RD-vpc.id
  tags   = local.defaults

}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.RD-vpc.id
  for_each          = var.public_subnets_cidr
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name      = "RD-vpc-public-${each.key}"
    Env       = "Dev"
    Purpose   = "Expose the service to outside world"
    Placement = "public"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.RD-vpc.id
  for_each          = var.private_subnets_cidr
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name      = "RD-vpc-private-${each.key}"
    Env       = "Dev"
    Purpose   = "Internal access"
    Placement = "public"

  }
}

resource "aws_eip" "nat-gateway-public-ip" {
  public_ipv4_pool = "amazon"
  domain           = "vpc"
  depends_on       = [aws_internet_gateway.gw]
  tags = {
    Name = "nat-gateway-public-ip"
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat-gateway-public-ip.id
  subnet_id     = aws_subnet.public["us-east-1a"].id

  tags = {
    Name = "RD-vpc-nat-gateway"
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.RD-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-route"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.RD-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "private-route"
  }
}

resource "aws_route_table_association" "public_ass0ciation" {
  for_each       = var.public_subnets_cidr
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id

}

resource "aws_route_table_association" "private_ass0ciation" {
  for_each       = var.private_subnets_cidr
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private.id

}