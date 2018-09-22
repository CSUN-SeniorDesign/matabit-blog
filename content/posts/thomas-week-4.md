---
title: "Thomas Week 4"
date: 2018-09-21T21:12:26-07:00
layout: 'posts'
draft: false
---

# Week 4
This week was all about finishing up the application load balancer and making sure it works properly. This involved ensuring the ALB was added to the correct subnets, attaching the correct instances to the target group to allow network traffic to reach the correct locations, and to enable HTTPS certificates to run on the ALB for network encryption/decryption.

## Attaching the ALB to subnets
In order to attach the ALB to specified subnets on our network we had to add the following lines to the ALB definition within the ALB.tf file:
```
subnets = [
                "${data.terraform_remote_state.vpc.aws_subnet_public_a_id}",
                "${data.terraform_remote_state.vpc.aws_subnet_public_b_id}"
              ]
```
By adding these lines, the ALB will be attached to public subnets A and B on the VPC.

## Attaching instances to our target group
The listeners on our ALB are setup to listen out for any traffic coming in on port 80 or 443, forward or redirect onto port 443, decrypt the data and send it to the target group. However, the target group needs to have endpoint attachments so the ALB has somewhere to forward that traffic. By adding the following lines into our terraform file, we were able to add our private EC2 instances as attachments to our target group to accept network traffic:
```
resource "aws_lb_target_group_attachment" "matabit_alb_tg" {
  target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
  target_id        = "${aws_instance.web.id}"
  port             = 80
}
resource "aws_lb_target_group_attachment" "matabit_alb_tg2" {
  target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
  target_id        = "${aws_instance.web2.id}"
  port             = 80
}
```
## Enabling SSL certificates on the ALB
The last issue that still needed to be resolved was figuring out how to enable SSL certification to run on the ALB. After doing some research and looking at terraform documentation, it was discovered that SSL certification could be added in the listener for our front end HTTPS. By adding the following lines to our frontend_https listener we were able to enable SSL certification:
```
ssl_policy = "ELBSecurityPolicy-2015-05"
certificate_arn = "${data.aws_acm_certificate.matabit.arn}"
```
## What still needs to be done
Before giving group presentation on Monday I still need to verify the information in my slides and make additional changes or additions. I also need to finish up my documentation for the project which includes both the documentation for the creation of our ALB terraform file as well as our service diagram which will outline the infrastructure of our AWS network and add it to our slides.