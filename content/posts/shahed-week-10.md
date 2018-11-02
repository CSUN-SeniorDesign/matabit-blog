---
title: "Shahed Week 10"
date: 2018-11-01T21:08:11-07:00
draft: false
layout: 'posts'
---

# Cheap Hosting, CDNs and SAPS


# Cheapest Hosting Option

Our cheap hosting solution ended up being to host all our assets on an S3 Bucket and to use CloudFront with Route53 to serve them to the users with a CDN.

It ended up costing less than a dollar a month and was the most efficient solution.

For the first time I've dealth with setting up a CDN. I've always heard about how companies like Netflix use them and how we include libraries through CDNs, but now dealing with it and how it works in more detail was very interesting.

I was tasked with securing the CDN with SSL. 

```

provider "aws" {
  region = "us-east-1"
}

resource "aws_acm_certificate" "matabit-cert" {
  domain_name       = "matabit.org"
  validation_method = "EMAIL"

  subject_alternative_names = ["*.matabit.org"]
}
```

Doing this was an easy task, as CloudFront only supports one region for the SSL certificate and that is US-East-1. From there all other regions will be secured as well for the Content Delivery Network.

CircleCI is still being used to push code into the S3 bucket on any commits to the Master branch. The IAM policy had to be adjusted for that to allow PUTs to the S3 Bucket.

# CSUN SAPS

I was assigned to the Permission Number system that CSUN is implementing for the IS and Comp Sci department. 

We managed to finally meet with the Computer Science Senior Design group that we are going to be working with and exchanged information.
Our goal is to not only support the developers to have an easier time deploying their code but to also improve and secure their infrastructure and to automate as much of that process as possible.

This is a very exciting project as it as close to a real world project that we could encounter in other companies as we possibly can at CSUN.


