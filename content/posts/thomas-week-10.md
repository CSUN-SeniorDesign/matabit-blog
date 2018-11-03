---
title: "Thomas Week 10"
date: 2018-11-02T22:04:24-07:00
layout: 'posts'
draft: false
---

# Project 5

For this past week we worked on project 5 which was an AWS implementation of the cheapest solution to hosting our blog that we determined in project 4. Ultimately we determined that the cheapest solution would be to contain the contentcs of our site in an S3 bucket and have a Cloudfront distribution fetch those contents and host the site. I was responsible for figuring out the new configuration needed for the CircleCI IAM user to be able to put objects into the S3 bucket.

## CircleCI IAM

Figuring out the CircleCI IAM account in Terraform was pretyy easy considering much of it was already there and just needed to be edited down for our new use case. In this case, the Terraform file creates the user account and assigns it to a group. It then creates a new policy for that group that allows CircleCI to gain access to the S3 bucket and to place objects within it.

```
provider "aws" {
  region = "us-west-2"
}

/* Circle CI User/Group */
resource "aws_iam_user" "circleci" {
  name = "circleci"
}

resource "aws_iam_group" "circleci" {
  name = "circleci"
}

resource "aws_iam_group_membership" "circleci" {
  name  = "circleci"
  users = ["${aws_iam_user.circleci.id}"]
  group = "${aws_iam_group.circleci.name}"
}

/* IAM Policies */
resource "aws_iam_group_policy" "circle-ci-put" {
  name  = "circle-ci-put"
  group = "${aws_iam_group.circleci.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "s3:PutObject",
              "s3:DeleteObject",
              "s3:ListBucket"
            ],
            "Resource": [
              "arn:aws:s3:::*/*",
              "arn:aws:s3:::matabit.org",
              "arn:aws:s3:::matabit.org/*"
              ]
        }
    ]
}
EOF
}
```

## Senior Design Project
For the rest of the time we discussed the senior design project and what would need to be accomplished before the end of next semester. I joined the Advancing Tech group and we took a brief tour of one of CSUN's data centers to look at the physical server racks we would be accessing and configuring. Later on we will be discussing group assignments and how we want to tackle the work that is ahead.