---
title: "Mario Week 1"
date: 2018-08-31T15:13:52-07:00
layout: 'posts'
draft: false
---
For the First week I setup my GitHub account and went through the tutorial to learn how to create and use a repository, start and manage a new branch, make changes and push them to GitHub as commits, and open and merge a pull request. I setup SSH on my commander console to log into a remote machine from my machine and execute commands. I also had to install Hugo on my machine. Hugo is a site generator written in Go designed for website creation. I installed Hugo so I can write my blog posts and send them over to our website.   For the first week I was also tasked with setting up the Route 53 to register our domain name Matabit.org using our EC2 instance. 

Amazon Route 53 is an available Domain Name System (DNS) on Amazons cloud computing platform, Amazon Web Services (AWS). Route 53 is a reference to TCP or UDP port 53, where the DNS server requests are Addressed. 

The way I went about setting up Route 53 was I opened the Route 53 console on the AWS website. Navigated to Hosted Zones. Clicked on Create Record Set, in the record set I entered our domain name Matabit.org. For the type I Chose A – Ipv4 address, for the Alias I accepted the default value of NO, the TTL I left at default which is 300, and for the value I entered the IP address we have setup for our Domain, finally I clicked create and the Route 53 was connected to our Ec2 domain name. This way Route 53 effectively connects your user requests to an infrastructure in AWS such as our EC2 instances. With Route 53 setup we can use it to configure DNS health checks to route traffic and monitor the health of the application to its endpoints. Also we Route 53 we are able to check traffic flows and create traffic policies as well as check our policy records. 


