# VPC

resource "aws_vpc" "dev_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "dev-vpc"
  }
}

# Public Subnet

resource "aws_subnet" "dev_subnet" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "dev-subnet"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

# Route Table

resource "aws_route_table" "dev_rt" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_igw.id
  }

  tags = {
    Name = "dev-route-table"
  }
}

# Route Table Association

resource "aws_route_table_association" "dev_rta" {
  subnet_id      = aws_subnet.dev_subnet.id
  route_table_id = aws_route_table.dev_rt.id
}

# Security Group

resource "aws_security_group" "dev_sg" {
  name        = "dev-sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.dev_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev-sg"
  }
}

# EC2 Instance

resource "aws_instance" "dev" {

  ami           = "ami-04a64102b8022e4f3"
  instance_type = "t3.micro"

  subnet_id              = aws_subnet.dev_subnet.id
  vpc_security_group_ids = [aws_security_group.dev_sg.id]

  tags = {
    Name = "dev-server-1"
  }
}