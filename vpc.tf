
provider "aws" {
  region = "eu-central-1"
}

//create vpc
resource "aws_vpc" "rcc_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "resistor_color_code-vpc"
  }
}

//create subnet
resource "aws_subnet" "rcc_subnet" {
  vpc_id                  = aws_vpc.rcc_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "resistor_color_code-subnet"
  }
}

//create subnet_2
resource "aws_subnet" "rcc_subnet_2" {
  vpc_id                  = aws_vpc.rcc_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "resistor_color_code-subnet-2"
  }
}

//create internet_gateway
resource "aws_internet_gateway" "rcc_igw" {
  vpc_id = aws_vpc.rcc_vpc.id

  tags = {
    Name = "resistor_color_code-igw"
  }
}

//create route_table
resource "aws_route_table" "rcc_rt" {
  vpc_id = aws_vpc.rcc_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rcc_igw.id
  }

  tags = {
    Name = "resistor_color_code-rt"
  }
}

//associate subnet to route_table
resource "aws_route_table_association" "rcc_rt_association" {
  subnet_id      = aws_subnet.rcc_subnet.id
  route_table_id = aws_route_table.rcc_rt.id
}

//associate subnet to route_table_2
resource "aws_route_table_association" "rcc_rt_association_2" {
  subnet_id      = aws_subnet.rcc_subnet_2.id
  route_table_id = aws_route_table.rcc_rt.id
}

//create a security group
resource "aws_security_group" "rcc_SG" {
  name   = "rcc-SG"
  vpc_id = aws_vpc.rcc_vpc.id

  tags = {
    Name = "resistor_color_code-SG"
  }
}

//create inbound rules for security group
resource "aws_vpc_security_group_ingress_rule" "rcc_inbound_rules" {
  security_group_id = aws_security_group.rcc_SG.id
  cidr_ipv4         = "0.0.0.0/0" //aws_vpc.rcc_vpc.cidr_block
  from_port         = 5001
  ip_protocol       = "tcp"
  to_port           = 5001
}

//create outbound rules for security group
resource "aws_vpc_security_group_egress_rule" "rcc_outbound_rules" {
  security_group_id = aws_security_group.rcc_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
