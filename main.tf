# Find the latest Amazon Linux 2 AMI
data "aws_ami" "amazon-linux-2" {
 most_recent = true

 owners = ["amazon"]

 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}

resource "random_pet" "pet_name" {
    # Used to give these server a unique name
}

# Create a keypair in AWS to use with the instance with a pre-generated keypair
module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = var.ssh_key_name
  public_key = var.ssh_public_key
}

# Create a security group that exposes SSH
resource "aws_security_group" "ssh_sg" {

  name        = "SSH"
  description = "Allows SSH connections on port 22"
  vpc_id      = aws_vpc.main.id


  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP from anywhere"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SSH"
  }
}

# Create a new VPC for the instance
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = random_pet.pet_name.id
  }
}

# Attach the VPC to a new internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = random_pet.pet_name.id
  }
}

# Create a route table for traffic to go over the internet
resource "aws_route_table" "rt" {
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
      Name = random_pet.pet_name.id
  }
}

# Associate the subnet to that route table
resource "aws_route_table_association" "b" {
  subnet_id     = aws_subnet.main.id
  route_table_id = aws_route_table.rt.id
}

# Create a new subnet for the instance
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  availability_zone = var.availability_zone
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = random_pet.pet_name.id
  }
}

# Create the instance itself
resource "aws_instance" "test_instance" {

 tags = {
     Name = random_pet.pet_name.id
 }

 ami                         = "${data.aws_ami.amazon-linux-2.id}"
 associate_public_ip_address = true
 instance_type               = var.instance_flavor
 key_name                    = var.ssh_key_name
 vpc_security_group_ids      = ["${aws_security_group.ssh_sg.id}"]
 subnet_id                   = "${aws_subnet.main.id}"
 availability_zone           = var.availability_zone
}