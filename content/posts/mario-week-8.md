---
title: "Mario Week 8"
date: 2018-10-18T21:27:28-07:00
layout: 'posts'
draft: false
---

# Week 8 Blog

Week 8's focus was to finish up AWS Route 53 and AWS ALB with the help from my team members. The other focus for week 8 as the project leader was to assign issues on Github for each team to work on the docs for the tasks they were assigned for the project. The last part of the project was to finish up the slides for our presentation. 

### Issues I faced

For this project, I assigned myself with the tasks of working on AWS Route 53 and AWS ALB. I had a problem understanding how to get the Route 53 and AWS ALB to work with the containers. I was confused with how to edit the already exiting ALB file we had to work with the containers. For the AWS Route 53, I was informed that nothing was needed to be done as the Route 53 file we had was already pointing to our ALB and nothing had to be done with the file.

## AWS Route 53 

For our AWS Route 53 file, nothing was needed to be done to the file as it was already pointing to our ALB. 

The file looks the same as it did from our last project 

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

## AWS Application Load Balancer ALB

For the ALB, several things needed to be added and changed. The first thing was the AWS ACM: a new certificate that includes these SANs: 

```
matabit.org, *.matabit.org, *.staging.matabit.org
```

The reason for that was because the ALB Listeners could not resolve the certificate correctly for the *.staging.matabit.org with the containers the way the EC2 instances were able to. 

The ALB now has two target groups which are:

```
target-group-ecs-staging 
target-group-ecs-prod
```

These two target groups are pointing to their respective ECS services that have control over the docker containers. So one for production and one for staging. 

An additional rule was added to the ALB Listener:

```
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

The ALB still contains the default rules:

```
#listen on port 80 and redirect to port 443
resource "aws_alb_listener" "frontend_http" {
  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    target_group_arn = "${aws_alb_target_group.alb_target_group_prod.id}"

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
    target_group_arn = "${aws_alb_target_group.alb_target_group_prod.id}"
  } 
}
```

Whenever the *staging.matabit.org route website is reached it will forward them to the ECS Staging service and all other traffic directed to the ALB will be redirected to the ECS Prod service.

## What's Next? 

For next week, we will be meeting with the computer science department students to work with for the remainder of the semester. 