---
title: "Thomas Week 3"
date: 2018-09-14T16:21:07-07:00
layout: 'posts'
draft: false
---

# Week 3
This week I was tasked with setting up the Terraform file for our Application Load Balancer. Terraform is something that is completely new to me so I spent the first couple of days reading about it and getting a general idea about what it is and how it works. I also read up on application load balancers and their purpose within a network. An ALB's main function is to take incoming traffic and route it evenly between multiple servers that are identical so that no one server gets overloaded with requests. After I had a general understanding of ALBs and Terraform I began to work on my Terraform file.

## Creating the Terraform file
Creating the terraform file proved a challenge but I was able to locate some online resources that aided in the process. 

The first step involved was defining the ALB. The defining process consisted of the following:

+ Giving the ALB a name.
+ Setting load balancer type to application.
+ Setting the ALB to external type.
+ Defining and attching a security group.
+ Setting the idle timeout (60s).
+ Enabling cross zone load balancing.
+ Enabling deletion protection.
+ Setting the availability zones (us-west-2a, us-west-2b, us-west-2c)

In addition, recording of access logs was created to log activity into a folder named "alb_access_logs" in our state bucket.

Timeouts were also set to 10 minutes each for any action that attempts to create, update or delete the ALB. Anything over this will be considered an error.

The ALB was also confifured to be attached to our public subnet B and has been given a static IP address.

### Security Group
The security group for the ALB has been set up with the following:

```ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
```

This will allow the ALB to accept incoming traffic on ports 80 and 443 (HTTP and HTTPS) from any IP address and send out traffic on any port to any IP address.

## Setting up redirection and forwarding
In order for the ALB to redirect traffic from port 80 to port 443, I had to set up ALB listeners. An ALB listener will listen to traffic coming in on a specific port and can take action on it depending on what was specified. 

One listener was created to listen for traffic on port 80 and forward it on port 443 towards the target group while another listener was created to simply forward any traffic found on port 443 to the target group.

## Issues that need to be addressed

The following issues need to be addressed to complete the ALB setup:

+ Ensuring the ALB is set up in the public subnets and availability zones.
+ Attaching the correct insrances to the target groups so that the ALB is routing traffic to the correct locations.
+ Attach https certificated so that traffic is encrypted accross the network.
+ Make sure ALB can also access private subnet instances.