---
title: "Mario Week 10"
date: 2018-11-01T15:28:11-07:00
layout: 'posts'
draft: false
---

# Senior Design Projects and Project 5 

## Senior Design Project
For week 10, I met up with other team members who chose the Advanced Tech for their Senior Design Project. We created a new slack channel to communicate on and talked about how the teams will be split up for the project. We also got a tour of the server room to see what we will be working with, including what is already available on them and what sort of tasks we will be implementing. Two of those tasks are implementing firewalls and ldap for the servers. 

## Project 5

For project 5, we had to implement the design we chose for our project 4 which was to find the most 
cost effective way to host our blog site. I was tasked with working on the S3 bucket. 

The S3 Bucket file looks as so: 

```
terraform {
  backend "s3" {
    bucket         = "matabit-terraform-state-bucket"
    region         = "us-west-2"
    dynamodb_table = "matabit-terraform-statelock"
    key            = "S3/s3.tfstate"
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "matabit" {
  bucket = "matabit.org"
  acl    = "public-read"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement":[{
  	"Sid": "AddPerm",
  	"Effect": "Allow",
  	"Principal": "*",
  	"Action": ["s3:GetObject"],
  	"Resource": ["arn:aws:s3:::matabit.org/*"]
  }]
}
 POLICY

  versioning {
    enabled = true
  }

  website {
    index_document = "index.html"
    error_document = "404.html"
  }
}
```

All we had to change with the S3 bucket file was the acl and add a policy. For the acl we changed it from ```"private"``` to ```"public-read"```. What this does is allows the cloudfront to access the files from the 
S3 bucket and grab the content to post onto the website to be viewable. For the policy we added down at the bottom of the file, this allows visitors to the site view the content.  