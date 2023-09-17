# creating vpc
  resource "aws_vpc" "main_vpc" { 
  cidr_block           = var.cidr_block
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"
  enable_dns_support   = "true"

  tags = {
    Name = "${var.project}_${var.env}_vpc"

  }
}
# creating public_subnet
resource "aws_subnet" "public_subnet" {
    count = 3
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = cidrsubnet(aws_vpc.main_vpc.cidr_block,4,"${count.index}")
 availability_zone = data.aws_availability_zones.available_zones.names["${count.index}"]
  tags = {
    Name = "${var.project}_${var.env}_public_subnet${count.index+1}"
  }
}
# creating private sunet
resource "aws_subnet" "private_subnet" {
    count = 3
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = cidrsubnet(aws_vpc.main_vpc.cidr_block,4,"${count.index+3}")
 availability_zone = data.aws_availability_zones.available_zones.names["${count.index}"]
  tags = {
    Name = "${var.project}_${var.env}_private_subnet${count.index+4}"
  }
}
# creating internet_gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.project}_${var.env}_igw"
  }
}
# creating public routetable
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  depends_on = [ aws_internet_gateway.igw ]
}
# public route table assocoation
resource "aws_route_table_association" "public_rt_association" {
    count = 3
  subnet_id      = aws_subnet.public_subnet["${count.index}"].id
  route_table_id = aws_route_table.public_route_table.id
}
# eip for the nat gteaway
resource "aws_eip" "natgw_eip" {
    domain   = "vpc"
    tags = {
      Name = "${var.project}_${var.env}_natgw_eip"
    }
}
# nat gateway creation
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.natgw_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "${var.project}_${var.env}_nat_gw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw,aws_eip.natgw_eip]
}
# route table for  private subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
}
# route table association with private subnet
resource "aws_route_table_association" "private_rt_association" {
    count = 3
  subnet_id      = aws_subnet.private_subnet["${count.index}"].id
  route_table_id = aws_route_table.private_route_table.id
}