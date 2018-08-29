---
title: "Shahed Week 1"
date: 2018-08-29T14:31:40-07:00
layout: 'posts'
draft: false
---

# How We Set Up The VPC

First off, a Virtual Private Cloud (VPC) is a section of the AWS cloud where you can launch and use AWS resources in. Basically, a virtual network.

We were tasked with setting up a VPC that consists of 3 public subnets, each with 1024 IP addresses, and 3 private subnets, each with 4096 IP addresses.
Additionally, two route tables and an internet gateway (igw).

The VPC needs an IPv4 CIDR block, which defines all the IP addresses that are available inside the VPC. Since we need 3,072 (3x1,024) addresses for the public subnet and 12,288 (3x4,096) addresses for the private subnet, we decided that for a total of 15,360 we need a /18 CIDR block, which assigns the VPC 16,384 addresses.

After the addresses were assigned to the VPC, we had to figure out what CIDR blocks were needed for the private and public subnets.
For the public ones, we decided for a /22 block, which gives each public subnet 1024 addresses.
For the private ones, we decided for a /20 block, which gives each private subnet 4096 addresses.

After all the private and public subnets were assigned, we made sure to create the correct routing tables. The public subnet needs a routing table that allows for internet traffic. This is where the internet gateway comes in. The internet gateway needs to be created for the public routing table to allow internet access and route all outgoing traffic to 0.0.0.0/0.
After the internet gateway has been attached to the public routing table, we made sure that it was set as the main table.
