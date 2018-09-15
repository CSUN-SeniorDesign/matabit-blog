---
title: "Mario Week 3"
date: 2018-09-14T22:57:02-07:00
layout: 'posts'
draft: false
---

# Terraform - EC2, Route53  

For week 3, the first thing I did was research and study up on two tools new to me which were Terraform and Ansible. These two tools were necessary to know in order to work on project 1. Before I started working with Terraform and Ansible I had to install Ubuntu on my PC and get familiar with it, because I was running Windows which Terraform and Ansible do not support. After I installed Ubuntu I had to use Terraform in order to setup our EC2 instance, Route 53, and User key instances for the project. I needed to learn Ansible in order to configure our webserver and Ansible playbook. I had also learned and read about resources that Terraform website provided me with in order to build our EC2,Route 53, and Key instances. The last thing I had to learn about was formatting and markdowns for my weekly blog posts. 

## Installing Ubuntu

Installing Ubuntu was fairly simple that took several steps. First step was to go to https://www.ubuntu.com/ and install and Iso image of Ubuntu. The second thing I had to download in order to boot it from a USB drive was Rufus from https://rufus.akeo.ie/. After both programs are downloaded, I run the Rufus program and pug in my USB drive. The Rufus program automatically recognizes the USB drive, then choose the ISO image from my desktop and click start to install it on the USB drive to make it bootable from any PC. After that was done I had to restart my PC and go into the Bios to change one setting to accept UEFI. After, I saved the setting and restarted my PC and clicked F12 to boot into the USB stick to begin the installation. The Installation asks you basic credential questions to setup an account and connect to WIFI. Getting familiar with Ubuntu OS was really simple as it looked like any other operating system. The last step I had to do was open my terminal and pull all my GitHub repositories and configure a new ssh key to work from my Ubuntu OS instead of my Windows OS. 

## Terraform - EC2 and Route 53 files 

What I learned from Terraform was that It allows us to code our Infrastructure. First I had to download and install Terraform from https://www.terraform.io/ and install it onto my terminal by typing the syntax sudo apt-get install terraform. 

An example of the private-ec2.tf file to create our EC2 instance looks like so: 

```
provider "aws" {
  region = "us-west-2"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config {
    bucket = "matabit-terraform-state-bucket"
    region = "us-west-2"
    key = "VPC/terraform.tfstate"
    name = "VPC/terraform.tfstate"
  }
}

resource "aws_instance" "web" {
  ami = "ami-51537029"
  instance_type = "t2.micro"
  subnet_id = "${data.terraform_remote_state.vpc.aws_subnet_private_a_id}"
  user_data = "${file("../cloud-init.conf")}"
  security_groups = ["${aws_security_group.web_sg.id}"]
  tags {
    Name = "matabit-private-ec2"
  }
}
```
For the Route 53 setup the Route53.tf file looks like this:

```
data "aws_route53_zone" "selected" {
  name         = "matabit.org."
  private_zone = false
}

 resource "aws_route53_record" "www" {
   zone_id = "${data.aws_route53_zone.selected.zone_id}"
   name    = "www.${data.aws_route53_zone.selected.name}"
   type    = "A"
   ttl     = "300"
   records = ["${aws_lb.web_lb.eip}"]
 }
```
with two more records (not shown) for our other IP's

## Whats Next?

For next week I will be using Ansible to configure our webserver and Ansible playbooks. Then providing documentation on setting up the EC2 and Route53 using Terraform as well as documentation on configuring the webserver and playbooks using Ansible. Finally, working on 

