---
title: "Thomas Week 8"
date: 2018-10-19T15:42:26-07:00
layout: 'posts'
draft: false
---

# Week 8
My main task for this week was finishing up the Terraform file for our ECS and preparing for the presentation we would be giving for the project. With the help of my teammates we were able to finish the ECS to host our staging and production environments.

## ECS creation

The following code was used to create our cluster and to assign it an IAM role allowing it to execute tasks:
```resource "aws_ecs_cluster" "matabit-cluster" {
  name = "matabit-cluster"
}


data "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"
}
```
## Task Definitions

We created two task definitions. One that defines our staging environment and one that defines our production environment. These definitions include our container definitions which are linked json files, our network mode, FARGATE capabilities, and task and execution roles. 
```
resource "aws_ecs_task_definition" "matabit-prod" {
  family                = "matabit-prod"
  container_definitions = "${file("task-definitions/matabit-prod.json")}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn = "${data.aws_iam_role.ecsTaskExecutionRole.arn}"
  execution_role_arn = "${data.aws_iam_role.ecsTaskExecutionRole.arn}"
  cpu = 256
  memory = 512
}

resource "aws_ecs_task_definition" "matabit-staging" {
  family                = "matabit-staging"
  container_definitions = "${file("task-definitions/matabit-staging.json")}"
  network_mode = "awsvpc"
  task_role_arn = "${data.aws_iam_role.ecsTaskExecutionRole.arn}"
  execution_role_arn = "${data.aws_iam_role.ecsTaskExecutionRole.arn}"
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512
}
```

The linked json files include definitions for our containers used in each environment. They include definitions such as the image ID, CPU and memory requirements, and the container port mappings. 

Production container definitions:
```
[
    {
      "name": "matabit-prod-container",
      "image": "485876055632.dkr.ecr.us-west-2.amazonaws.com/matabit-ecr:prod",
      "cpu": 10,
      "memory": 512,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ]
    }
]
```

Staging container definitions:
```
[
    {
      "name": "matabit-staging-container",
      "image": "485876055632.dkr.ecr.us-west-2.amazonaws.com/matabit-ecr:staging",
      "cpu": 10,
      "memory": 512,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ]
    }
]
```
## ECS Service

Also included in the Terraform file are two ECS service blocks that further define how our ECS will operate. Here we can assign the service to our cluster and include task definitions. We can also configure our network settings by including the security groups and assigning the cluster to our private subnets. Lastly, we attached our load balancer target group so that our ALB can direct traffic towards our ECS.
```
resource "aws_ecs_service" "matabit-prod-service" {
  name            = "matabit-prod-service"
  cluster         = "${aws_ecs_cluster.matabit-cluster.id}"
  task_definition = "${aws_ecs_task_definition.matabit-prod.arn}"
  desired_count   = 2
  launch_type = "FARGATE"
  

  network_configuration {
    security_groups = ["${aws_security_group.security-lb.id}"]
    assign_public_ip = true
    subnets = [
      "${data.terraform_remote_state.vpc.aws_subnet_private_a_id}",
      "${data.terraform_remote_state.vpc.aws_subnet_private_b_id}",
      "${data.terraform_remote_state.vpc.aws_subnet_private_c_id}",
    ]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.alb_target_group_prod.id}"
    container_name   = "matabit-prod-container"
    container_port   = 80
  }
}
resource "aws_ecs_service" "matabit-staging-service" {
  name            = "matabit-staging-service"
  cluster         = "${aws_ecs_cluster.matabit-cluster.id}"
  task_definition = "${aws_ecs_task_definition.matabit-staging.arn}"
  desired_count   = 2
  launch_type = "FARGATE"
  

  network_configuration {
    security_groups = ["${aws_security_group.security-lb.id}"]
    assign_public_ip = true
    subnets = [
      "${data.terraform_remote_state.vpc.aws_subnet_private_a_id}",
      "${data.terraform_remote_state.vpc.aws_subnet_private_b_id}",
      "${data.terraform_remote_state.vpc.aws_subnet_private_c_id}",
    ]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.alb_target_group_staging.id}"
    container_name   = "matabit-staging-container"
    container_port   = 80
  }
}
```