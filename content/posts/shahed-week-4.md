---
title: "Shahed Week 4"
date: 2018-09-17T16:21:30-07:00
draft: false
layout: 'posts'
---

# Load Balancers, TLS and more Terraform

## Problems...
We faced several issues during the second week:
1. Application Load Balancer did not work
2. Let' Encrypt wouldn't create certificates
3. The ALB doesn't take Elastic IPs


## How Did We Fix These Problems?

### 1. Application Load Balancer Did Not Work

The ALB had three specific issues that prevented us from successfully connecting to the Private EC2 Instances.
1. The ALB Listener for HTTPS did not work because it had no certtificate attached to it. We talk more about solving this issue in the third problem-fix.
2. The target-group used the wrong port to route traffic. We were using Port 443 to route traffic instead of Port 80.
3. The target-groups were not attached to any instances. No "aws_lb_target_group_attachment" was defined.

So we switched the route traffic port to port 80 and made sure to attach the target groups to the right aws instance by doing the following...

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

By using these resources we made sure that all the routes were attached and were listening and registered on the correct port.

We only need to use port 80 because the ALB is going to take care of all the encryption/decryption of traffic.

### 2. Let' Encrypt wouldn't create certificates

To create a TLS certificate with Let's Encrypt it would expect us to set the _acme-challenge TXT value in our Route53. So when we would enter the TXT values into our DNS it would still error out saying it coudln't find any NXDOMAIN entries for it.

After consulting with the professor we realized it would be easier to simply use AWS's Certificate Manager and attach the certificate to our ALB using the following setting in our `aws_alb_listener` resource.

```
certificate_arn = "${data.aws_acm_certificate.matabit.arn}"
```

Through this we managed to correctly deploy our resources.

### 3. The ALB doesn't take Elastic IPs

Now that our ALB was set up we still had no way to get the traffic from our Private EC2 instances. After some research, we noticed it would make sense to create Alias A records which would route traffic from `blog.matabit.org`, `www.matabit.org` and `matabit.org` to the ALB's public DNS name.
So we set those records in Route53 and thus managed to successfully access our Private EC2 instances through the ALB.


```
resource "aws_route53_record" "alb-record-www" {
  zone_id = "${data.aws_route53_zone.selected.id}"
  name    = "www.matabit.org."
  type    = "A"

  alias {
    name = "${aws_lb.alb.dns_name}"
    zone_id = "${aws_lb.alb.zone_id}"
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "alb-record-blog" {
  zone_id = "${data.aws_route53_zone.selected.id}"
  name    = "blog.matabit.org."
  type    = "A"
  alias {
    name = "${aws_lb.alb.dns_name}"
    zone_id = "${aws_lb.alb.zone_id}"
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "alb-record-apex" {
  zone_id = "${data.aws_route53_zone.selected.id}"
  name    = "matabit.org."
  type    = "A"
  alias {
    name = "${aws_lb.alb.dns_name}"
    zone_id = "${aws_lb.alb.zone_id}"
    evaluate_target_health = true
  }
}
```