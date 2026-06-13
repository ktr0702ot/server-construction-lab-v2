terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "vpc_cidr" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "terraform-ansible-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.vpc_cidr.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "terraform-ansible-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.vpc_cidr.id
  tags = {
    Name = "terraform-ansible-igw"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.vpc_cidr.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "terraform-ansible-rtb"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id       = aws_subnet.main.id
  route_table_id  = aws_route_table.main.id
}

resource "aws_security_group" "main" {
  name    = "terraform-ansible-sg"
  vpc_id  = aws_vpc.vpc_cidr.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
    Name = "terraform-ansible-sg"
  }
}

resource "aws_key_pair" "main" {
  key_name   = "terraform-ansible-key"
  public_key =  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+zSni65ny0keoMCgdlSdYJ41piQuCzHAgd1Lj+t+P2w5UcDu+yxwulRLWVsARmBj3HgKhqlP2WSoC0SbvdjiyY7XdV1StjIIVNYwLhWpiURFgmmUMvbtsRNHw82XUyrxg4Tj1sdDzDUk3Bx2KQbYmstUtz7VkfwHpTodrLxRio32Mj0xZgJ+GcnKqc7i8hG+YSI15MHP+S9vToOdBbNiyoEDRoA02ktq3dTOPbNHhI+DVMtrKnisqVWE+fgAEtxwcYPIHgqP5bminFfl79MlNRtJFf/NitHBGYmRf3CqGuDnzV4WhqSjSoCneHlPVnHSBO9z8jsJ8UEpWaQ4OhWstnuj0NNE10NcjdZJ8l1AKiiPPxaxt5UINGaREpXstfvzRtSzqJbsxGpfxpPyGUVDjMWee9371bxrxdBhFH1fD+cBLuutjjlzyNtJkAMuGrOoZFYdqs8eZTrpkINzPho26o7ddJxzqibFn0om1YWY0SWI2UZNiwkOqT7O2iN+9F4ez6bGyGUv2y8AVnLgiMj5HKWC3lQijtLzn/9cObSvKA4aBt6aPLQ7oREYV//zXIxCi39WVPuTE4bPdDnb6EfSylMDBuY08mn3F6M1dW0g8Uc4DalhUcZFnFiVQhIbwiXYeIcTZUNNJdNumNwOu7EVUZEUnjtPUp7cRL7hM6IePuQ=="
}

resource "aws_instance" "main" {
  ami                         = "ami-0599b6e53ca798bb2"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.main.id]
  key_name                    = aws_key_pair.main.key_name
  associate_public_ip_address = true
  tags = {
    Name = "terraform-ansible-ec2"
  } 
}