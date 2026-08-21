# --------------------------------------------------
# VPC
# --------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.cluster_name}-vpc"
    Project = var.project_name
  }
}


# --------------------------------------------------
# Internet Gateway
# --------------------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.cluster_name}-igw"
    Project = var.project_name
  }
}


# --------------------------------------------------
# Public Subnets
# --------------------------------------------------

resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.cluster_name}-public-${count.index + 1}"
    Project = var.project_name

    "kubernetes.io/role/elb" = "1"
  }
}


# --------------------------------------------------
# Private Subnets
# --------------------------------------------------

resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.cluster_name}-private-${count.index + 1}"
    Project = var.project_name

    "kubernetes.io/role/internal-elb" = "1"
  }
}


# --------------------------------------------------
# Public Route Table
# --------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "${var.cluster_name}-public-rt"
    Project = var.project_name
  }
}


# --------------------------------------------------
# Public Route Table Associations
# --------------------------------------------------

resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


# --------------------------------------------------
# Elastic IP for NAT Gateway
# --------------------------------------------------

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name    = "${var.cluster_name}-nat-eip"
    Project = var.project_name
  }

  depends_on = [
    aws_internet_gateway.main
  ]
}


# --------------------------------------------------
# NAT Gateway
# --------------------------------------------------

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name    = "${var.cluster_name}-nat"
    Project = var.project_name
  }

  depends_on = [
    aws_internet_gateway.main
  ]
}


# --------------------------------------------------
# Private Route Table
# --------------------------------------------------

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # This does NOT expose private instances to the Internet.
  # It only provides outbound Internet access through NAT.
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name    = "${var.cluster_name}-private-rt"
    Project = var.project_name
  }
}


# --------------------------------------------------
# Private Route Table Associations
# --------------------------------------------------

resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}