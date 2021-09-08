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

  key_name   = "Dylan Taylor"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDYsYRK9LXIbqJ2LVXQMTun/hUxhiHtSZMVOyjVjAFAWD0heeUUuSRLvvCI97PF3xAIvJaeeICjK0zzaHO67TP0HMzdfRrmjJyYNS7CKopG5U49OYZd6L98vBEKtNBcug1e0LMVUqOPwmhr4fu+g9/0TXPQpksJk6fiNKjjhVu4fRET3G5nvvQuHvclFzRCupR0EkGMrNIwF5pSFQMz1dHtQ6pder7u+Vun4TmPfVRnB4nMnRW7uN5/F/zqvcX0ey/UYe65Kf7LTeadbWb9sVQ9YgxN71YjwsSqBwE84ih9Q3Twgqig/kFhzPEkw3pxsClZjpsf4QF++ONlybzqkApCDYBvMCrewFT53OzEmFOndQoNBh8P6qMtHaDKX/CO5cJ7wu+z0O5rXx88aHPxuaJ9+0sB2ZY5UuoD0o/0GxcATNkpZXvkKiFhHw+6FfQkdIZScSRlHAiqBMnkrIjR9CMibSgflIPer5y3qIHq4nXlwO7y+Hf6HkEe2TYmYnrs/hs= taylord@ITL-X-TAYLORD.local"
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

# Create a new subnet for the instance
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  availability_zone = var.availability_zone
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}

# Create the instance itself
resource "aws_instance" "test_instance" {

 tags = {
     Name = random_pet.pet_name.id
 }

 ami                         = "${data.aws_ami.amazon-linux-2.id}"
 associate_public_ip_address = true
 instance_type               = "t3a.micro"
 key_name                    = "Dylan Taylor"
 vpc_security_group_ids      = ["${aws_security_group.ssh_sg.id}"]
 subnet_id                   = "${aws_subnet.main.id}"
 availability_zone           = var.availability_zone
}