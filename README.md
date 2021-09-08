This is a simple Terraform example that I built to learn how to use SSM and build an EC2 instance in the Curi playground environment. 

Using the AWS provider

https://registry.terraform.io/providers/hashicorp/aws/latest/docs

this builds a t3a.micro instance with an SSH key created by Terraform (reference https://registry.terraform.io/modules/terraform-aws-modules/key-pair/aws/latest). This uses the Amazon Linux 2 AMI instead of RHEL or something that costs money (reference https://www.hashicorp.com/blog/hashicorp-terraform-supports-amazon-linux-2).


