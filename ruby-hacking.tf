# Set us up the provider
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

# Define a basic VPC
resource "aws_vpc" "rubyhacking" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags {
    Name = "rubyhacking"
  }

}

# Create a security group to allow ssh
resource "aws_security_group" "rubyhacking" {
  name = "rubyhacking"
  description = "SG for Ruby Hacking VPC"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "rubyhacking"
  }

  vpc_id = "${aws_vpc.rubyhacking.id}"
}

# Subnet
resource "aws_subnet" "rubyhacking" {
  cidr_block = "10.0.0.0/24"

  tags {
    Name = "rubyhacking"
  }

  vpc_id = "${aws_vpc.rubyhacking.id}"
}

# Define a route table
resource "aws_route_table" "rubyhacking" {
  vpc_id = "${aws_vpc.rubyhacking.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.rubyhacking.id}"
  }
}

# Define a route table association
resource "aws_route_table_association" "rubyhacking" {
  subnet_id = "${aws_subnet.rubyhacking.id}"
  route_table_id = "${aws_route_table.rubyhacking.id}"
}

# Attach an internet gateway
resource "aws_internet_gateway" "rubyhacking" {
	vpc_id = "${aws_vpc.rubyhacking.id}"
}

resource "aws_instance" "rubyhacking" {
  ami = "${var.aws_ami}"
  instance_type = "${var.aws_instance_type}"
  key_name = "${var.aws_key_name}"

  connection {
    user = "${var.aws_user_name}"
    key_file = "${var.aws_key_path}"
  }

  security_groups = ["${aws_security_group.rubyhacking.name}"]

  provisioner "remote-exec" {
    inline = [
        "echo ohhai >> /var/tmp/muhfile"
    ]
  }

  tags {
    Name = "rubyhacking"
  }

}
