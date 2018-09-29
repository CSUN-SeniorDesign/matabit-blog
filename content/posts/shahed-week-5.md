---
title: "Shahed Week 5"
date: 2018-09-28T09:40:19-07:00
draft: false
layout: 'posts'
---

# Route53, NGINX and Packer

This week we had a little bit of a late start due moving last projects due date, so things got a little hectic in the beginning.
However, I think we found our rhythm again and are on track to finish everything on time.
I have been tasked with configuring Route53 for the staging environment, making sure that the ALIAS A records for the staging environment
are created. Additionally, I've been tasked with preparing the new NGINX configuration to include the staging environments and also adding the
X-Private-IP and X-Hostname Header fields.
Finally, I've been tasked with creating our own AMI with Packer to include all the configuration needed to spin new instances up and down with ASG.

## Route 53

For Route53 it was pretty straight forward. We basically just had to extend our ALIAS A Records to include the following in Terraform:

```
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

With these resource blocks we are making sure that the correct DNS names for the staging server forward to the ALB which then distributes between the ASGs.

## NGINX

The NGINX configuration had to be changed to account for two environments instead of the default one.
Now, since we have a production and a staging environment, we have to have two separate server blocks, which respond to certain "server names" or rather DNS hostnames.

Here's what we had to change to allow for that to happen.

```
server {
	listen 80 default_server;
	listen [::]:80 default_server;

	root /var/www/prod/matabit-blog/public;

	index index.html index.htm index.nginx-debian.html;

	server_name www.matabit.org blog.matabit.org matabit.org;

	location / {
		try_files $uri $uri/ =404;
		add_header X-Hostname $hostname;
		add_header X-Private-IP $server_addr;
	}
}

server {
	listen 80 default_server;
	listen [::]:80 default_server;

	root /var/www/staging/matabit-blog/public;

	index index.html index.htm index.nginx-debian.html;

	server_name www.matabit.org blog.matabit.org matabit.org;

	location / {
		try_files $uri $uri/ =404;
		add_header X-Hostname $hostname;
		add_header X-Private-IP $server_addr;
	}
```

Basically we are setting the root for the two environments to two separate folders (staging and prod)
and then we add the respective servernames.

Additionally, as per requirements, we added the two header attributes `X-Hostname` and `X-Private-IP` which can be set with
`$hostname` and `$server_addr` respectively. This way NGINX can dynamically figure out the Hostname and Private IP of the Server it is on without having to
hard code any values.

## Packer

Packer is the tool that we use to create our own AMIs so that we can ensure that all instances that are spun up by the Auto Scaling Group are the same and have all the configuration and files preinstalled.

Basically what Packer will do is create an EC2 Instance, run any provisioners needed that will configure the instance, stop the instance and then create an AMI out of that, which can be referenced by an AMI ID

The packer config is written in JSON.
Here's what we have so far. It is still incomplete.

```
{   
    "provisioners": [
        {
            "type": "ansible-local",
            "playbook_dir": "../Ansible/playbooks/project1",
            "playbook_file": "../Ansible/playbooks/project1/main.yml"
        }
    ],
    "builders": [{
        "type": "amazon-ebs",
        "region": "us-west-2",
        "source_ami_filter": {
            "filters": {
                "virtualization-type": "hvm",
                "name": "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*",
                "root-device-type": "ebs"
            },
            "owners": "[amazon]",
            "most_recent": true
        },
        "instance_type": "t2.micro",
        "ssh_username": "ubuntu",
        "ami_name": "matabit-ami {{timestamp}}"
    }]
}

```

This will be continued during Week 6

