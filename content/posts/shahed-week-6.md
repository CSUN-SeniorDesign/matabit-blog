---
title: "Shahed Week 6"
date: 2018-10-04T09:44:05-07:00
draft: false
layout: 'posts'
---

# Packer, ASG, Ansible, Datadog

Since last week a lot of our configuration has changed. We learned a lot about Packer and how Auto Scaling Groups work.
I've been working on a lot of different aspects of this project since a lot of it is dependent on one another.

## Packer & Ansible & Datadog

Our Packer configuration hasn't changed much since last week.
Mostly the provisioners have been adjusted.

We now have one Shell Provisioner and one Ansible local provisioner.

```
  "provisioners": [
        {
            "type": "shell",
            "script": "provision.sh"
        },
        {
            "type": "ansible-local",
            "playbook_dir": "../Ansible",
            "playbook_file": "../Ansible/playbooks/project2/playbook.yml" 
        }
    ]
```

The entire playbook directory and the shell script get uploaded to the remote instance and then executed locally.
The shell provisioner is responsible for the initial setup.

```
#!/bin/bash
set -e
#provision.sh
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y python-dev python-pip
sudo pip install ansible
sudo DD_API_KEY=<API-KEY> bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/datadog-agent/master/cmd/agent/install_script.sh)"
```

The provisioner script does the initial setup by installing python dev dependencies so that we can install ansible.
Additionally, it installs the datadog-agent.

After the shell provisioner is executed on the EC2 Instance, it continues with the Ansible provisioner.
```
---
- name: Run the playbook tasks on the localhost
  hosts: 127.0.0.1
  connection: local
  roles: 
    - update-cache
    - nginx
    - mkdir-env
    - establish-index-nginx
    - nginx-hugo
    - install-aws-cli
    - configure-datadog
    - ec2-get-blog
```

This is the playbook that we're running. Essentially, we're making sure that the ansible script runs on the localhost and then run all the roles in order.
The most essential new additions are the `install-aws-cli` role, `configure-datadog`, and `ec2-get-blog`.

### install-aws-cli
We need to install the AWS cli so that the `get-s3.sh` script can pull the necessary .tar files from the S3 Bucket to deploy the blog.
We're installing the AWS CLI using the pip module.

```
---
  - name: Install AWS CLI
    become: true
    pip:
      name: "{{ item }}"
      state: present
      extra_args: --upgrade
    with_items:
      - awscli

```

### configure-datadog

Datadog needs certain configuration files to pass on the correct metrics to the dashboard.
We're passing these configuration files using the template module

```
---
  - name: Change http_check template
    become: true
    template:
      src: http_check.yaml
      dest: /etc/datadog-agent/conf.d/http_check.d/conf.yaml
  - name: Change nginx template
    become: true
    template:
      src: nginx.yaml
      dest: /etc/datadog-agent/conf.d/nginx.d/conf.yaml
  - name: Change ssh_check template
    become: true
    template:
      src: ssh_check.yaml
      dest: /etc/datadog-agent/conf.d/ssh_check.d/conf.yaml
  - name: Restart DataDog
    become: true
    command: systemctl restart datadog-agent
```

### ec2-get-blog

This part has been done by Anthony Inlavong.
This ansible role makes sure that the get-s3.sh script is on the EC2 Instance and then set as a cronjob that executes every 5 minutes.

---
  - name: Copy get-s3.sh script to /usr/local/bin
    become: true
    template:
      src: get-s3.sh
      dest: /usr/local/bin/get-blog
      mode: +x
  
  - name: Set crontab to get lastest blog version
    become: true
    cron: 
      minute: "*/5"
      job: "/usr/local/bin/get-blog >/dev/null 2>&1"


## ASG

Thomas was responsible for the creating of the ASG, however, the ASG was depending on the AMI that packer created to spin up the correct instances.
One of the issues that we encountered during the configuration of the ASG was that it wouldn't register the target instances in the Application Load Balancer at all.
So, to fix that we used the following resource:

```
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = "${aws_autoscaling_group.asg.id}"
  alb_target_group_arn   = "${aws_alb_target_group.alb_target_group.arn}"
}
```
This way the Auto Scaling Group would know which Target Group to register to.


Another issue that we were facing with the Auto Scaling Group was that it would fail during the initial startup with terraform.
And still, it wouldn't register the target groups. That is because of a lifecyclehook that we had initially included in our configuration.
This life cycle hook was waiting on a CloudWatch Event to return something and since that wasn't set up it would just get stuck.
Once we removed the life cycle hook everything worked correctly.

The biggest problem that we were facing in Project #2 were the many dependencies that we suddenly had.
From Packer to IAM to Ansible and Datadog, everything was very tightly integrated and if one part failed another wouldn't work.
Debugging the problems was a very valuable experience.
      









