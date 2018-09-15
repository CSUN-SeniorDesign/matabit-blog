---
title: "Shahed Week 3"
date: 2018-09-13T20:51:19-07:00
draft: false
layout: 'posts'
---

# Terraform - IAM, VPC's and private EC2's

## What's Terraform?
Terraform was a completely new tool new to me. I had heard of the name before but I never used it and didn't even know what it was for.
I was excited by the thought of having to learn it!
Terraform basically helps us provision AWS resources automatically and dynamically.

## What I learned
Here's a list of things that I had to pick up on to efficiently use Terraform within the group project:
1. Providers
2. Resources
3. Backends
4. States/Remote States/State Lock
5. Data Sources
6. Terraform Variables

## Preparation for Project 1 
Before we started anything, I made sure that our AWS account was cleared out of everything, so that we had a clean slate to work on! That meant to get rid of the VPC, IAM users, EC2 Instances, Security Groups, Routing Tables... everything basically! 
The only thing we kept was Route53 for the sake of simplicity but more on that later.

## Provisioning IAM users
The first task that I was assigned, and on which everyone depended to do their work efficiently, was to set up all the IAM users from scratch. 

#### Password Policy

I wanted to make sure that all IAM users will have secure password so I set up a password policy like this:

```
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 6
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = false
  require_symbols                = true
  allow_users_to_change_password = true
}
```

Basically ensures that a diverse string is chosen for a strong password.

#### Group Policy

I also made sure that a correct group with an attached group policy is created, which gives all users "Administrator Access".
Additonally, group memberships had to be defined.

#### Secret/Key Access

Due to security concerns, all the users had to log in via their newly created IAM account, create a new password, and then download the Secret Access Key and ID themselves. This way no secrets would be shared over the internet.

## Helping out with the VPC

I was initially tasked to create the NAT/Bastion instance, but due to the nature of the VPC set up, Anthony took it upon himself to help me out with the NAT/Bastion configuration.

There were struggles with the VPC in that we couldn't properly set up cloud-init, so i helped identify the problem. 
We couldn't SSH into our NAT/Bastion instance because our public keys were denied. First, we tried it with key-pairs but that wouldn't work so we tried initializing our instances with user-data and we utilized cloud-init to do so.

When we used cloud-init it wouldn't initially work due to an type error in the beginning of the file.

## Helping out with the private EC2 Instance

Mario was tasked with setting up the EC2 instance, however, that turned out to be more difficult than expected so I started helping out with the service infrastructure.

We needed to read some remote-state variables from the VPC section and that turned out to be a little more difficult. After much research, we found out that the VPC variables have to be explicitly "output" so that others can read them through the data-source terraform_remote_state. 

This is how we configured the data-source:
```
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config {
    bucket = "matabit-terraform-state-bucket"
    region = "us-west-2"
    key = "VPC/terraform.tfstate"
    name = "VPC/terraform.tfstate"
  }
}
```

## How do we jump from the Bastion to the EC2 instance?

One major problem that we encountered, while trying to connect to the EC2 instance in the private subnet, was that we didn't know how to carry over our private key so that we can ssh from our localhost to the NAT/Bastion instance and then from there onto the private EC2 instance. Eventhough we had cloud-init setup on the EC2 instance, it wouldn't grant us access with SSH our public SSH key. We finally figured out with some help that we need to add our private key to our SSH-agent and then use the '-A' flag to SSH onto the Bastion and then from there onto the EC2 instance.




