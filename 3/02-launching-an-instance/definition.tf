variable "subnet_id" {}

data "aws_subnet" "selected" {
  id = "${var.subnet_id}"
}

provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

resource "aws_security_group" "web-pub-sg" {
  name        = "web-pub-sg"
  description = "Web Pub"
  vpc_id = "${data.aws_subnet.selected.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["189.40.102.177/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_network_interface" "www1-eth0" {
  subnet_id       = "${data.aws_subnet.selected.id}"
  private_ips     = ["10.1.254.10"]
  security_groups = ["${aws_security_group.web-pub-sg.id}"]
}

resource "aws_eip" "eip" {
  vpc      = true
}

resource "aws_eip_association" "eip_assoc" {
  network_interface_id = "${aws_network_interface.www1-eth0.id}"
  allocation_id = "${aws_eip.eip.id}"
  private_ip_address = "10.1.254.10"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGeyFZOgWjU2cdWpL3jGcr7QKYU2db8BDLNaS6EpAZvDTOUwSIRjXmbFvxZEPecsXxwzC3wwOeIxEEaE+pMGyi/sFvj8FhblbOahiRolDNtdJPbJ07bKHd9XOfczcSK/z/ocU5sSdPJy3mTuClSgiauwzHGOBeAc/zQi5yeTvkUnJr23gAuMtVleQAoU3dOoa6kh7JG+vwFOkFhgf/8fwsBFYktxKRTjG+6hl8lIduzLwVnznxPLXXeHex8zqHe4Aq47cTsY+/WyY7pQiqnZZXeG7Vaew+PxkyaSEUwianHFMRROm4x7IvuS07Kj6wgqfIHV0g2hlFyPjzCaTji/1p rhnascimento@Renatos-MacBook-Air.local"
}

resource "aws_instance" "web" {
  ami           = "ami-1cb6b467"
  instance_type = "t2.micro"
  
  network_interface {
      network_interface_id = "${aws_network_interface.www1-eth0.id}"
      device_index = 0
  }

  key_name = "${aws_key_pair.deployer.key_name}"

  tags = {
    Name = "www1"
  }
}
