---
title: "Anthony Week 3"
date: 2018-09-14T19:30:09-07:00
layout: 'posts'
draft: false
---
# Terraform - VPC, SSH Bastions, NAT
This week's focus were the tools Terraform and Ansible. Terraform allow us to code our infrastructure and Ansible allows us to provision that infrastructure. I assigned myself as team lead this week to handle the management of tasks and to help the group out. Originally, I was working on the Service Infrastructure part of the project but swapped tasks to create the VPC due to the urgency. 

## Getting started
Before starting with Terraform I made sure to include my AWS API key to my aws-cli configure file. This should always be done because you don't want to hard code this into your terraform code, nasty things happen if you upload your AWS api keys publicly.

## Creating the Resource, Variable, and Output Terraform files
 To get started, I created a VPC directory in our Terraform directory of the infrastructure repo. This allows use to separate out Terraform code. Inside I created two files initially, the `VPC.tf` and `variables.tf` files. The VPC file will contain all the resource blocks for creating our VPC's infrastructure. The variables file stored all the variables used for the VPC. This included things like cidr blocks, IP address, etc. I worked on the VPC files but edited the variables whenever I needed to pull data in.

## The Variables file
The `variables.tf` file looks like this (Obviously with more info):

``` Terraform
variable "aws_region" {
  description = "Main Matabit VPC"
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default     = "172.31.0.0/16"
}

variable "public_subnet_cidr_a" {
  description = "CIDR for the public subnet-a"
  default     = "172.31.2.0/22"
}


variable "private_subnet_cidr_a" {
  description = "CIDR for the private subnet-a"
  default     = "172.31.16.0/20"
}


variable "aws_route53_matabit_zone_id" {
  description = "Hosted zone ID for Matabit"
  default     = "Route53-hosted-zone-ID"
}
```

You define data you want hard coded here. Its a good practice to bring in variables just in case something changes within the infrastructure. 
This allows a btt of modularity. 

## The Resource blocks
The resource block file contains all the AWS resources that will be used. I referenced the variables from the `variables.tf` file for a few of the resources. The entire file is around 257 lines of code so I won't be showing all of the code. If you would like to view the Terraform file visit the [Github link](https://github.com/CSUN-SeniorDesign/matabit-infrastructure/blob/master/Terraform/VPC/VPC.tf). With the help of Shahed, we were able to implement a remote state in an S3 bucket so we all can access variables from our separate terraform directory. I'll explain this later. The main part of this task was to recreate our previous infrastructure but add a NAT/Bastion host. Sample code below: 

``` Terraform
terraform {
  backend "s3" {
    bucket = "matabit-terraform-state-bucket"
    region = "us-west-2"
    key    = "VPC/terraform.tfstate"
  }
}

# Define AWS as our provider
provider "aws" {
  region = "${var.aws_region}"
}

# Define our VPC
resource "aws_vpc" "default" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "matabit-vpc"
  }
}

```

## Bastion/SSH
Creating the Bastion/NAT instance was quite a journey. It had Shahed and I scratching our heads around every corner. One issue we had we our cloud-init file. It simply wouldn't run however a small syntax error was the root of the problem. After it was configured, we were able to SSH into our bastion but not the private EC2 instances. Turns out we had to add the NAT as one of the incoming security groups and allow ssh forwarding which you can [read about here](https://github.com/CSUN-SeniorDesign/matabit-infrastructure/blob/master/docs/aws_docs/aws-ssh-bastion-forwarding.md). 

## Creating outputs
After the VPC was created we had to share the variables of the resource blocks to other Terraform files. To do this we had to create an `outputs.tf` file to define the variables we wanted to share. This allows other Terraform files to reference things such as VPC IDs and IP's addresses without hard coding them after the VPC script is ran. It makes our infrastructure more dynamic. A sample of the output looks like: 

``` Terraform
# Outputs
output "vpc_id" {
  value = "${aws_vpc.default.id}"
}

output "nat_sg_id" {
  value = "${aws_security_group.nat.id}"
}

output "nat_instance_id" {
  value = "${aws_instance.nat.id}"
}
```