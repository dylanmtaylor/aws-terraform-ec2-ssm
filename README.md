This is a simple Terraform example that I built to learn how to build AWS Terraform infrastructure using SSM.

Using the AWS provider https://registry.terraform.io/providers/hashicorp/aws/latest/docs, this builds a t3a.micro instance with an SSH key imported using Terraform (reference https://registry.terraform.io/modules/terraform-aws-modules/key-pair/aws/latest). This uses the Amazon Linux 2 AMI as it has SSM pre-installed and does not cost money to use.

An SSH security group is created to expose port 22 and ICMP to incomming connections from anywhere and also allows full egress to everything. All of the other requisite resources for network connections are created as well, including a VPC, subnet, route table, and a route table association for that subnet so that it uses the internet gateway.

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association