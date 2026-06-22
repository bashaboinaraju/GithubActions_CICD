# VPC

resource "aws_vpc" "test_vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "test-vpc"
  }
}

# Public Subnet

resource "aws_subnet" "test_subnet" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "ap-south-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "test-subnet"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.test_vpc.id

  tags = {
    Name = "test-igw"
  }
}

# Route Table

resource "aws_route_table" "test_rt" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_igw.id
  }

  tags = {
    Name = "test-route-table"
  }
}

# Route Table Association

resource "aws_route_table_association" "test_rta" {
  subnet_id      = aws_subnet.test_subnet.id
  route_table_id = aws_route_table.test_rt.id
}

# Security Group

resource "aws_security_group" "test_sg" {
  name        = "test-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.test_vpc.id

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
    Name = "test-sg"
  }
}

# EC2 Instance

resource "aws_instance" "test" {

  ami           = "ami-04a64102b8022e4f3"
  instance_type = "t3.micro"

  subnet_id              = aws_subnet.test_subnet.id
  vpc_security_group_ids = [aws_security_group.test_sg.id]

  tags = {
    Name = "test-server-1"
  }
}