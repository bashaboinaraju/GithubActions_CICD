resource "aws_instance" "dev" {

  ami           = "ami-04a64102b8022e4f3"
  instance_type = "t3.micro"

  tags = {
    Name = "test-server"
  }
}