---
title: "Thomas Week 6"
date: 2018-10-05T14:25:40-07:00
layout: 'posts'
draft: false
---

# Week 6
For week 6 I was repsonsible for finishing up the ASG as well as preparing the documentation, creating the service diagram, and getting everything ready for the presentation.

## ASG
In order to finish up with the ASG, I had to create the configuration to determine what type of EC2 instances it would create. To do this, I created an aws_launch_configuration resource at the top of my asg file and referenced it from my aws_autoscaling_group resource. 

```
resource "aws_launch_configuration" "asg_conf" {
  name_prefix = "terraform-"
  image_id      = "ami-03705bf93ac3a378e"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.web_sg.id}"]
  user_data = "${file("../cloud-init.conf")}"
  iam_instance_profile = "${data.terraform_remote_state.circleci.ec2-get-iam-role}"

  lifecycle {
    create_before_destroy = true
  }
}
```

The image id references the AMI ID that Shahed created with Packer. Instance type was set to t2.micro and we attched a security group to limit incoming traffic to our instances. User data is included to specify our group member rsa keys and the iam instance profile will associate the ec2-get-iam role with our launched instances. 

The following lines of terraform code were used to define how our ASg should work.

```
resource "aws_autoscaling_group" "asg" {
  name                      = "asg-matabit"
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.asg_conf.name}"
  vpc_zone_identifier       = ["${data.terraform_remote_state.vpc.aws_subnet_private_a_id}", "${data.terraform_remote_state.vpc.aws_subnet_private_b_id}"]
  target_group_arns         = ["${aws_alb_target_group.alb_target_group.arn}"]
  wait_for_capacity_timeout = "15m"
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = "${aws_autoscaling_group.asg.id}"
  alb_target_group_arn   = "${aws_alb_target_group.alb_target_group.arn}"
}
```

Based on the configuration above, our ASG will be set to spin up 2 EC2 instances and can spin up to a total of 4 if needed. It will perform ELB health checks on our instances and can terminate any instances it finds are unhealthy. The launch configuration that was defined at the top of the file has now been attached to our ASG and we have defined in which subnets we want our EC2 instances in (Private A and B). 

We ran into an issue with attaching our ALB but Shahed was able to fix this issue by adding an ASG attachment that specifies our ALB target group. I am not sure why an attachment needed to be made when terraform documentation states that your ALB target group can be defined within the ASG resource but adding the attachment did seem to work out.

I was able to add a schedule to our ASG which will terminate and create our instances on whichever schedule we create.

```
resource "aws_autoscaling_schedule" "asg_schedule_on" {
  scheduled_action_name  = "asg_on"
  min_size               = 2
  max_size               = 4
  desired_capacity       = 2
  recurrence             = "0 13 * * *"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}

resource "aws_autoscaling_schedule" "asg_schedule_off" {
  scheduled_action_name  = "asg_off"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = "0 8 * * *"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}
```
For now we have it set up so that our ASG will have a desired capacity of 2 EC2 instances at 6am PST (1pm UTC) and will thus create 2 EC2 instances every day at that time. We also set it up for our ASG to turn off every day at 1am PST (8am UTC) by setting the desired capacity to 0. This way our ASG will terminate any running instances at this time and won't spin up any others until 6am.

## Documentation
I have documented my work on the ASG and will wait for everyone to complete their documentation before posting our final project to Canvas. I will need to finish up our service diagram by adding the ASG s3 buckets and add that to our documentation later.

## Next week
Next week we will be working on a new project that will involve creating containers to host our web content. To prepare for this I will be reading up over the weekend about what containers are and how they work.