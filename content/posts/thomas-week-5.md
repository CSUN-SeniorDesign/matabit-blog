---
title: "Thomas Week 5"
date: 2018-09-28T22:58:03-07:00
layout: 'posts'
draft: false
---

# Week 5
This week I was made team leader for Project 2. Part of my initial responsibilities as team leader was to evenly divide up the workload into issues and to assign them to each team member. I assigned each member a task of their own and a shared task between themselves and another member. In addition, I made sure that each member had a task that differed from what they have been doing in our previous projects to prevent information silos. For this project I have assigned myself with setting up the auto-scaling group and the S3 bucket.

## ASG
The auto-scaling group will be able to create and distroy EC2 instances based on the needs of the network. This process should be created to happen automatically but also allow manual access from administrators. 

It consists of two components: the asg file and its configuration.

The configuration will specify what type of EC2 instance to create and what properties it should have. This is where we can pass the AMI ID to be used to create our instances.

It also has the ASG file which will be used to run the actual logic of our instances and can create and destory instances.

Here's what I have so far for the ASG file:
```
resource "aws_placement_group" "aws_placement" {
  name     = "aws_placement"
  strategy = "cluster"
}

resource "aws_autoscaling_group" "asg" {
  name                      = "asg-terraform"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 4
  force_delete              = true
  placement_group           = "${aws_placement_group.aws_placement.id}"
  launch_configuration      = "${aws_launch_configuration.foobar.name}"
  vpc_zone_identifier       = ["${aws_subnet.example1.id}", "${aws_subnet.example2.id}"]

  initial_lifecycle_hook {
    name                 = "foobar"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 2000
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

    notification_metadata = <<EOF
{
  "foo": "bar"
}
EOF
```

Some of these values still need to be adjusted as they were placeholders for examples.

## S3
I also tasked myself with creating a new S3 bucket that will store our packaged website created through CircleCI/CD and will allow access from our EC2 instances to utilize that data. These packages will need to be tracked over time and be able to label the latest version for easy targeting.

Right now it is unsure if policies will need to be created and utilized within the S3 bucket or if they can be created and attached to the CircleCI IAM account and the EC2 instances in some other way.

```
provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "cci_bucket" {
  bucket = "cci-bucket"
  acl    = "private"

  versioning {
      enabled = true
  }

  tags {
    Name        = "cci_bucket"
    Environment = "Dev"
  }
}
```

## What needs to be done
For the next week I need to finish up the ASG file and create its configuration file to reference. I also need to determine if the S3 bucket requires policies to be placed within it or if they should be defined elsewhere. I also need to work together with Anothony to work on the script that will automatically check the S3 bucket for new updates and install them to our staging site.