---
title: "Thomas Week 2"
date: 2018-09-07T02:21:40-07:00
layout: 'posts'
draft: false
---

# Week 2
The tasks assigned to me for week 2 included preparing the documentation for setting up our EC2 instance, installing nginx on the EC2 instance, and also creating the network diagram that represents the infrastructure of our AWS network. In addition, I was tasked with helping create the presentation slides for our group presentation and prepare to discuss my contributions to the project.

## Creating the documentation
For the documentation on how the EC2 instance was setup, I included details regarding what kind of instance was setup and how the security group setup within our VPC was configured to limit incoming and outgoing traffic. I also explained how our EC2 instance became associated with an elastic IP address that would be used in our Route53 table to have our domains point to it. Lastly, I documented that our public SSH keys were added into the /home/ubuntu/.ssh/authorized_keys file so that we may remotely connect to our EC2 instance via SSH for configuring and maintaining the server.

I also created the documentation regarding the installation of nginx on our EC2 instance. I documented commands used to install nginx and configuration of Ubuntu's firewall to allow traffic on port 80, 443, and 22. In addition, the details on how we configured traffic on port 80 to automatically reroute to HTTPS was documented alongside the creation of SSL certificates to allow HTTPS to encrypt data sent across the network.

For the AWS network diagram I used an online tool called draw.io. With draw.io you can create a large variety of diagrams for different types of networks all with built-in tools and specific icons designed for different infrastructures. Using the AWS set of icons I was able to create a network diagram representative of our infrastructure. For the diagram I was sure to include the VPC, public and private subnets, security group, EC2 instance and nginx webserver, internet gateway, and Route53 table. After the diagram was finshed I uploaded it to its own branch and used the link as a reference for markdown in my documentation file.

## Preparing the presentation
For the rest of my time during week 2 I was preparing for our group presentation by helping out with creating the slides about my different tasks and responsibilities. I also focused on what I learned these past 2 weeks and prepared to talk about that for bit during our presentation. Having never used github before I have definitely learned a lot about how to clone repos, create new branches, edit files, commit changes and submit pull requests. I also learned quite a bit about AWS and the services it provides and its general infrastructure. To prepare for the coming weeks I'll be doing research on our upcoming tasks to hopefully be as prepared as I can for what's ahead.
