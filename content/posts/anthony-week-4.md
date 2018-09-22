---
title: "Anthony Week 4"
date: 2018-09-21T19:25:30-07:00
layout: 'posts'
draft: false
---

# Anthony's 4th week
This week's focus was fixing some issues related the VPC/NAT and helping out with Ansible. A few small changes to the cloud-init file was made too.

## The NAT instance and incorrect CIDR blocks
We had though we had the VPC up and running along with a few EC2's in the service infrastructure. We've connected two EC2 into our VPC both in private subnet
A and B respectively. We will call them EC2-a and EC-b. I was able to ssh into EC2-a and pull-down updates with no issues. EB2-b 
was accessible via SSH, however it could not pull update/it didn't have network access. This was an issue cause by an improper configuration
with the NAT's Security rules. We only allowed private Subnet A to access the internet which signifies only private subnet A 
can talk to the outside world. To fix this we specified the VPC's CIDR blog. This allowed the other subnets such as those on subnet b, to gain
access to the outside world.

Original ingress rule block
```Terraform
ingress {
  from_port   = 443	    from_port   = 443
  to_port     = 443	    to_port     = 443
  protocol    = "tcp"	    protocol    = "tcp"
  cidr_blocks = ["${var.private_subnet_cidr_a}"]	    
  }
```

New ingress rule block
```
ingress {
  from_port   = 443	    from_port   = 443
  to_port     = 443	    to_port     = 443
  protocol    = "tcp"	    protocol    = "tcp"
  cidr_blocks = ["${var.private_subnet_cidr_a}"]	    cidr_blocks = ["${var.vpc_cidr}"]
  }	  
```

## Cloud-init not setting Bash as the default shell
When cloud-init was configured we didn't specific a specific shell to use. By default it used a shell that didn't include table complete
or backspace, which was mildly infuriating. All we had to do is specify the shell with cloud-init which carried on to all EC2 instances

```
#cloud-config
users:
  - name: anthony
    password: RANDOM
    ssh-authorized-keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHoI/6eB3puRtQ+xngXaBR3bfBperpnl7VqaGGmF56uLoKs6pCW8zqrnxIaUSMhqgea7+h4Yhf0RgTaRfWoByoMu5Wm9m5f9AedZ7V+FKr3tsVZQNtBXcjSjiXHUEgiTMLvZbl4ZzaWkT0YF4Birjg6PMxS64NnSZwCPUa3G5pcSA28EteAc9jecauxaBFfDI0kv9xtgwWLG8ByZ7uDCYXbaAGVwNlF7whhfHHH3L1x0vthGgH2yrdnkwrCK4HM3AdLiRSTJWIN7ueirENmaZBn3c0tpMzqeKQQfxTemENmYmX3AfRS4vsGOzgkoqX+SVevm+yzDwk/Gue33lFFrB/RO8jsDdgRncqu8L9OLYxkEkKYKtnJq41oT0oHtXm9cr/FciYqU+P5J3El/t48ItLaOnMy1tUvonHGslFazoPYbylVserKACtdu2Qr631Znh9ECquNV/oaQE6MYsl0rnQ6qCYRswyo87aWzU7lqIbzgHnki3Wk0ATUPVmr4OtKvIBXLGR5arYibZ4LfJYpVoeMYw6LXBsN5ukq0dFmcwLNOoZ2pIjNdP8roRNTewg4NOEWoKQ5kAS6k5ky3IA4YneEXjav0UDiA6a5umaWGpQCDlFZvG1RWCMPkG79HpZ2UbW0IYYJFTcFfxI0AL3qrZHq8WlyITPuFPTBVlGdFbVoQ== anthony.inlavong@gmail.com
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    shell: /bin/bash
```

## Ansible with SSH forwarding
I've never use Ansible with ssh forwarding so this was new to me. Many of the of tutorials on the internet were convoluted or outdated. 
After trial and error, I was able to run Ansible scripts locally that provisioned our private EC2 instances. We had to specify a ssh argument in the
hosts inventory file. We also had to change a few things with the `ansible.cfg` file because it threw prompts for ssh key checking which we couldn't enter input for.
This is insecure; however, it was one workaround we had to do.

ansible.cfg
```
[defaults]
hostfile=hosts.ini
roles_path=../../roles
host_key_checking = False

[ssh_connection]
# bump up from 60s
ssh_args = -C -o ControlMaster=auto -o ControlPersist=30m
```

hosts.ini
```
[server:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q anthony@ssh.matabit.org"'
```
