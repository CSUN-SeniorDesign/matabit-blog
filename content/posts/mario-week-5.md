---
title: "Mario Week 5"
date: 2018-09-27T21:44:20-07:00
layout: 'posts'
draft: false
---

# IAM and DataDog

For week 5 project 2 consists of using CircleCi for Continuous Integration and CD for Continuous Deployment. We will continue to build off the base of what we have previously built with Terraform and Ansible. We will be how we build and run our blog posts along with how to deploy it. The point of this is to use the new deployment method and get operations out of the equations when developers want to get a new version of our blog posts out to users. We will look at how to automate our build and test it using a pipeline which will take in new changes to the master branch, to make sure everything works successfully, then package up the blog and push the package to somewhere it can be downloaded by others. The two important tools we will be using to accomplish this is CircleCi and DataDog. For this assignment I have been tasked with setting up and IAM user account for CircleCI using Terraform and DataDog to track specific information and additional metrics. 

## DataDog 

For DataDog, I have not got to working with it yet but it is used for monitoring service for cloud-scale applications, providing monitoring of servers, databases, tools, and services, through a SaaS-based data analytics platform. DataDog uses Python based open-source agent that helps developers and operation teams to view their full infrastructure such as cloud, servers, apps, services, and metrics. For us we will be using DataDog to track information like CPU usage, CPU load averages, Memory usage by the system, Disk usage on the system, and process uptime. As well as a custom config or plug in to track the number of requests to our website, latency for requests to our website, and status codes of requests to our server (2xx, 3xx, 4xx,5xx). Some additional metrics we will be tracking is Logins over SSH to our bastion host, Unsuccessful logins over SSH, Cronjob run successful/failed, staging site updated, and production site updated. It should be able to do these actions as part of our base AMI.

## IAM

For IAM, I am to use Terraform to create an IAM user account for CircleCI. 

First I created an aws iam group and user account for CircleCI:

```
resource "aws_iam_group" "circleci-group" {
  name = "circleci"
}

resource "aws_iam_user" "circleci" {
  name = "circleci"
}
```
then, I created an aws iam group membership for CircleCI: 

```
resource "aws_iam_group_membership" "circleci" {
  name = "circleci-membership"
  users = [
      "${aws_iam_user.circleci.id}"
  ]
  group = "${aws_iam_group.circleci-group.name}"
}
```

The last step was to create a aws IAM policy for CircleCI: 

```
resource "aws_iam_policy" "circleci-policy" {
  name = "circleci-policy"
  description = "policy for circleci"
  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutAnalyticsConfiguration",
                "s3:PutAccelerateConfiguration",
                "s3:DeleteObjectVersion",
                "s3:ReplicateTags",
                "s3:RestoreObject",
                "s3:CreateBucket",
                "s3:ReplicateObject",
                "s3:PutEncryptionConfiguration",
                "s3:DeleteBucketWebsite",
                "s3:AbortMultipartUpload",
                "s3:PutBucketTagging",
                "s3:PutLifecycleConfiguration",
                "s3:PutObjectTagging",
                "s3:DeleteObject",
                "s3:DeleteBucket",
                "s3:PutBucketVersioning",
                "s3:DeleteObjectTagging",
                "s3:PutMetricsConfiguration",
                "s3:PutReplicationConfiguration",
                "s3:PutObjectVersionTagging",
                "s3:DeleteObjectVersionTagging",
                "s3:PutBucketCORS",
                "s3:PutInventoryConfiguration",
                "s3:PutObject",
                "s3:PutIpConfiguration",
                "s3:PutBucketNotification",
                "s3:PutBucketWebsite",
                "s3:PutBucketRequestPayment",
                "s3:PutBucketLogging",
                "s3:ReplicateDelete"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
```

The second part of this which I have not got to yet is to create least privileges, to put action against S3 Bucket. Final step is to create a GET action for EC2 Instance to assign instance role and fetch the data from S3 using AWS CLI/SDK cron job. 

## What's Next? 

For next week, I will be finishing up the tasks for DataDog. As well as work on the documentation for project 2 and prepare for the presentation. 