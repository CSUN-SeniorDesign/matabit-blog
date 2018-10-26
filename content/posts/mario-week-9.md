---
title: "Mario Week 9"
date: 2018-10-25T21:01:04-07:00
layout: 'posts'
draft: false
---

# Senior Design Projects and Project 4

For this week we had multiple lectures about different projects to work on for the Senior Design class. We are to choose one project as a team that stands out the most to us and group up with a team from the computer science design class to work on for the remainder of the semester going into the next semester. Some of the projects to work on were the Estate Attorney, CSUN's Academic progression system, the irrigation system around campus, and building a web server for CSUN. In addition, we had project 4 to work on which was to find the most cost effective way to host our blog site. 

## Senior Design Projects

For the senior design projects I come to find two of them that stood out the most to me. The first one is the CSUN Academic Progression system. I found this one interesting because it is more of what we have been working on in-class projects from the beginning of the semester. This gives me a chance to get a better understanding of the tools we used such as Terraform, Ansible, and CircleCI work. 

The second project that stood out to me was building a webserver for the campus. I found this project interesting because it involves hands-on work with server hardware, in which I find myself performing better in. 
In addition, it also involves working with Terraform, Ansible, and CircleCi to get the server running. With this project I get to experience both the hands-on side and infrastructure side. 

## Project 4

For project 4 we are to find the most cost effective way to host our blog site using the Amazon AWS calculator for 1000 requests per day. My task for the project was to create a diagram to show the method we chose to find the most cost effective way to post our blog site. 

We have Route 53 serving the domain for the website. Route 53 will then route traffic to a CloudFront, a CDN service will grab the blog contents from an S3 bucket. The s3 bucket will then populate the latest post using Continuous delivery with CircleCI. The CircleCI will have IAM access to the S3 bucket for PUT permissions. The AWS infrastructure is deployed with Terraform so it can easily bring the infrastructure up and down. In the end, we found out that it will cost us $0.04-$0.05/month to host our blog site. 