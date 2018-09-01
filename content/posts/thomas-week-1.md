---
title: "Thomas Week-1"
date: 2018-08-31T21:35:24-07:00
layout: 'posts'
draft: true
---

During week 1 I was able to install git and hugo on my local machine to allow me to make changes to our github repos remotely and post new blog entrees. I registered my machines public ssh key on github in order to gain access to our github repo remotely through SSH. 

I was given the task of installing nginx on our ubuntu server running through EC2 on AWS so that we can start serving basic webpages over our webserver. I sent my public SSH key to be input into the EC2 instance for remote connection. Once I was able to login via SSH to our ubuntu server I began running the commands to install nginx. Once it was installed I configured the firewall to allow traffic through only the necessary ports. These ports were 22 for SSH, 80 for http, and 443 for https. Once this was configured I ran the command to start the nginx service and was able to verify that it was working properly by connecting to the server via its public IP address and seeing the basic nginx webpage displayed.