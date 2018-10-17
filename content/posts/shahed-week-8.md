---
title: "Shahed Week 8"
date: 2018-10-17T10:29:59-07:00
draft: false
layout: 'posts'
---

# Finalizing the ECS and the VPC

We left off week seven with being able to run only one environment. We were trying to configure our containers as if they were hosted on EC2 Instance when we were in fact using AWS Fargate.

## AWS Fargate

AWS Fargate allows us to run our containers without having to think about any of the server configuration or about scaling our EC2 instances properly. Fargate does all of that for us. All we have to say is which container to use, what the CPU and MEMORY requirements are and what network configurations to use. 

# Our problem...

When using ECS, it would create its own services which have their own respective target groups. The target group that we were creating initially would not register the containers correctly. So in the ALB listener we would manually add rules for the correct services, but due to conflicts with the default route it would only route the rule with the highest priority.

So when we finally transferred everything over to terraform instead of going through the management console, we managed to correctly identify the target groups and associate them with the correct services and listeners.



Here's what that looks like: 
## Services
```bash
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
```

The essential part is the following:

```bash
  load_balancer {
    target_group_arn = "${aws_alb_target_group.alb_target_group_prod.id}"
    container_name   = "matabit-staging-container"
    container_port   = 80
  }
```

Here we are associating the service with a target group and specifying the container port to which it should route the traffic to. We do this twice for each environment: prod and staging.

These target groups are defined as part of the ALB:

## Target Groups
```bash
#create target group
resource "aws_alb_target_group" "alb_target_group_prod" {
  name        = "target-group-ecs-prod"
  port        = "80"
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  health_check {
        healthy_threshold   = "5"
        unhealthy_threshold = "2"
        interval            = "30"
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = "5"
    }
  tags {
    name = "target-group-ecs-prod"
  }
}
```

The listener had to be changed to forward to the production target group by default:
## ALB Listener
```
#listen on port 443 and forward traffic
resource "aws_alb_listener" "frontend_https" {
  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${data.aws_acm_certificate.matabit.arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.alb_target_group_prod.id}"
  } 
}
```

## Additonal Listener Rules

The additional rule is to forward all routes that hit *staging.matabit.org to the staging service:

```bash
resource "aws_lb_listener_rule" "matabit-staging" {
  listener_arn = "${aws_alb_listener.frontend_https.arn}"
  priority = 10

  action = {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.alb_target_group_staging.id}"
  }
  condition = {
    field = "host-header"
    values = ["*staging.matabit.org"]
  }
}
```

## HTTPS doesn't work...
SSL wouldn't work for the routes at `*.staging.matabit.org`.
Oddly enough, the same certificate worked for Project 2, which was dealing with EC2 instances,
however, the ALB had trouble veryfing the certifcate for containers. So we updated the certificate and added `*.staging.matabit.org` as a SAN. Afterwards, HTTPS traffic was allowed for all routes.

# Making the Containers Private

Initially, for testing purposes, we had all the containers set up in public subnets, which is not best practice, since it would leave those containers vulnerable to attacks.

When moving the containers to private instances, they would get stuck in a "Pending" status, which means they couldn't pass the health checks to transition to a "Running" status. After further research, i found out that since the containers are in private instances, they have no way to communicate to the outside. The ALB in this case would only route inbound traffic, and the containers had no way to respond.

So to fix that we had to add a NAT Gateway to a public subnet, and have a private route table point to that NAT Gateway. That way all the private outbound traffic is going through the NAT Gateway, and thus have a way to communicate with the outside world.

Here's how we implemented that: 

```bash
# EIP for NAT Gateway
resource "aws_eip" "nat" {
  vpc = true
  tags {
    Name = "NAT-EIP"
  }
}

# NAT Gateway for Fargate
resource "aws_nat_gateway" "gateway" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public-subnet-a.id}"

  tags {
    Name = "Fargate-NAT"
  }
  
  depends_on = ["aws_route_table.public-rt"]
}

# Private Route Table with NAT Gatewaye
resource "aws_route_table" "private-rt" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gateway.id}"
  }

  tags {
    Name = "private-subnet-route-table"
  }

  depends_on = ["aws_route_table.public-rt"]
}
```

