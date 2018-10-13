---
title: "Posts"
date: 2018-10-11T21:11:43-07:00
layout: 'posts'
draft: false
---

# Week 7 Blog

For week 7, I was made the Team leader for Project 3. My responsibilities as team leader was to evenly divide up the tasks of Project 3 into issues on GitHub and assign the issues to each team member. In addition, I had to make sure that each team member had a task different from that they worked on in the previous project to prevent information silos. For this project I assigned myself the tasks of setting up the AWS Route 53 and AWS ALB for the DockerFile container. 

## AWS ALB

For the AWS ALB, the traffic to our site should still be forwarded from an ALB from clients. 

Our Current ALB.tf looks as so:

```
data "aws_acm_certificate" "matabit" {
  domain      = "matabit.org"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

#define ALB
resource "aws_lb" "alb" {
  name                             = "aws-lb"
  internal                         = false
  load_balancer_type               = "application"
  security_groups                  = ["${aws_security_group.security-lb.id}"]
  idle_timeout                     = "60"
  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false

  subnets = [
    "${data.terraform_remote_state.vpc.aws_subnet_public_a_id}",
    "${data.terraform_remote_state.vpc.aws_subnet_public_b_id}",
    "${data.terraform_remote_state.vpc.aws_subnet_public_c_id}"
  ]

  tags {
    Name = "matabit-alb"
  }

  timeouts {
    create = "10m"
    delete = "10m"
    update = "10m"
  }
}

# Security Group: Load Balancer
resource "aws_security_group" "security-lb" {
  description = "Allow the world to use HTTP from the load balancer"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress {
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
  }

  tags {
    Name = "matabit-alb-sg"
  }
}

#listen on port 80 and redirect to port 443
resource "aws_alb_listener" "frontend_http" {
  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    target_group_arn = "${aws_alb_target_group.alb_target_group.id}"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

#listen on port 443 and forward traffic
resource "aws_alb_listener" "frontend_https" {
  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${data.aws_acm_certificate.matabit.arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.alb_target_group.id}"
  }
}

#create target group
resource "aws_alb_target_group" "alb_target_group" {  
    name = "target-group-web"  
    port = "80"  
    protocol = "HTTP"  
    vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"   
    tags {    
        name = "target-group-web"    
    }   
    stickiness {    
        type = "lb_cookie"    
        cookie_duration = 1800    
        enabled = true
    }   
    
    health_check {    
        healthy_threshold = 3    
        unhealthy_threshold = 10    
        timeout = 5    
        interval = 10
        path = "/"    
        port = "80"  
    }
}
```

I will have to add more to it in order for it to work with our container. 

## AWS Route 53

For the AWS Route 53, the DNS traffic still needs to go through Route 53 for any queries to access our site. 

Here is what the Route53.tf file looks like:

```
data "aws_route53_zone" "selected" {
  name         = "matabit.org."
  private_zone = false
}

resource "aws_route53_record" "alb-record-www" {
  zone_id = "${data.aws_route53_zone.selected.id}" # Replace with your zone ID
  name    = "www.matabit.org."                     # Replace with your name/domain/subdomain
  type    = "A"

  alias {
    name                   = "${aws_lb.alb.dns_name}"
    zone_id                = "${aws_lb.alb.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "alb-record-blog" {
  zone_id = "${data.aws_route53_zone.selected.id}" # Replace with your zone ID
  name    = "blog.matabit.org."                    # Replace with your name/domain/subdomain
  type    = "A"

  alias {
    name                   = "${aws_lb.alb.dns_name}"
    zone_id                = "${aws_lb.alb.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "alb-record-apex" {
  zone_id = "${data.aws_route53_zone.selected.id}" # Replace with your zone ID
  name    = "matabit.org."                         # Replace with your name/domain/subdomain
  type    = "A"

  alias {
    name                   = "${aws_lb.alb.dns_name}"
    zone_id                = "${aws_lb.alb.zone_id}"
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "alb-record-www-staging" {
  zone_id = "${data.aws_route53_zone.selected.id}" # Replace with your zone ID
  name    = "www.staging.matabit.org." # Replace with your name/domain/subdomain
  type    = "A"

  alias {
    name = "${aws_lb.alb.dns_name}"
    zone_id = "${aws_lb.alb.zone_id}"
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "alb-record-blog-staging" {
  zone_id = "${data.aws_route53_zone.selected.id}" # Replace with your zone ID
  name    = "blog.staging.matabit.org." # Replace with your name/domain/subdomain
  type    = "A"
  alias {
    name = "${aws_lb.alb.dns_name}"
    zone_id = "${aws_lb.alb.zone_id}"
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "alb-record-apex-staging" {
  zone_id = "${data.aws_route53_zone.selected.id}" # Replace with your zone ID
  name    = "staging.matabit.org." # Replace with your name/domain/subdomain
  type    = "A"
  alias {
    name = "${aws_lb.alb.dns_name}"
    zone_id = "${aws_lb.alb.zone_id}"
    evaluate_target_health = true
  }
}
```

## What's Next?

For next week, I will complete my task of setting up the AWS ALB file if I have not done so over the weekend. Then the team and I will make sure our infrastructure functions properly before turning the project in. We will also have to complete documentation for the project and as team leader I will have to setup the power point and prepare for our presentation. 