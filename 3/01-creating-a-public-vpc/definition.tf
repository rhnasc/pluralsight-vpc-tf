provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

resource "aws_vpc" "web-vpc" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "web-pub" {
  vpc_id     = "${aws_vpc.web-vpc.id}"
  cidr_block = "10.1.254.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "web-pub"
  }
}

resource "aws_route_table" "web-pub" {
  vpc_id = "${aws_vpc.web-vpc.id}"

  tags = {
    Name = "web-pub"
  }
}

resource "aws_route_table_association" "web-pub" {
  subnet_id      = "${aws_subnet.web-pub.id}"
  route_table_id = "${aws_route_table.web-pub.id}"
}

resource "aws_internet_gateway" "web-igw" {
  vpc_id = "${aws_vpc.web-vpc.id}"

  tags = {
    Name = "web-igw"
  }
}

resource "aws_route" "web-igw-route" {
  route_table_id = "${aws_route_table.web-pub.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.web-igw.id}"
}
