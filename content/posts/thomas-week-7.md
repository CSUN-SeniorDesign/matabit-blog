---
title: "Thomas Week 7"
date: 2018-10-12T22:21:12-07:00
layout: 'posts'
draft: false
---

# Week 7
I started my week 7 by taking a look at what docker and containers are and how they are created and operate. After watching a few videos on the topic I had a better understanding of what it was we are trying to implement for this project and how/why it'll be an improvement over our current use of EC2 instances to host our content. For this project I was assigned with the task of ECS creation in terraform.

## ECS
ECS stands for Elastic Container Cluster and it's where our containers that run our blog will be. Our cluster should be designed so that it is automatically scalable based on a set of criteria and should also register to our ALB. 

## Create the cluster
```
data "aws_ecs_cluster" "ecs" {
  cluster_name = "matabit-ecs"
}
```

## Container definition
The container definition will allow access to the details of a container within our cluster.

These details include: 
+ The docker image
+ Image digest
+ The CPU limit
+ The memory limit
+ Memory soft limit
+ Environment in use

I will need to continue to fill out these details to specify the which image our containers will use and what kind of resources to give them.

## Task definition
I am currently unsure of exactly how the ECS task definition data source is supposed to work. I will do more research on the matter over the weekend to determine how it should be used and how I can implement it into our ECS configuration.

## ECS service
The ECS service data source will allow us to define the details of a service within ECS. Here we can determine the number of tasks we would like to run, the launch type, our scheduling strategy and our reference to our task definition data source. Once I figure out how I can implement our task definition I will create the service data source as well.

## What next
I will continue to work this weekend on figuring out the different configuration components of our ECS. I will also work with Mario who is working on our ALB configuration to figure out how to register the ECS with the ALB. After this is figured out I will write out the documentation and prepare for the presentation on Thursday.