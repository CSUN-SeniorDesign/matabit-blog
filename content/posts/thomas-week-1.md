---
title: "Thomas Week-1"
date: 2018-08-31T21:35:24-07:00
layout: 'posts'
draft: false
---

During week 1 I was able to install git and hugo on my local machine to allow me to make changes to our github repos remotely and post new blog entrees. I registered my machine's public ssh key on github in order to gain access to our github repo remotely through SSH. I learned how to use hugo to create blog posts, how to clone github repos to my local machine, how to setup a new branch and create files for the branch, how to push the changes to github and create pull requests to request the new files to be inserted into the repo.

In addition, I was given the task of installing nginx on our ubuntu server running through EC2 on Amazon web services so that we can start serving basic webpages over our webserver. I generated and sent my public SSH key to be input into the EC2 instance for remote connection. Once I was able to login via SSH to our ubuntu server I began running the commands to install nginx. Once it was installed I configured the ubuntu firewall to allow traffic through only the necessary ports. These ports were 22 for SSH, 80 for http, and 443 for https. Once this was configured I ran the command to start the nginx service and checked the status with the command "systemctl status nginx" to verify it was running properly. I was also able to verify that it was working properly by connecting to the server via its public IP address and seeing the basic nginx webpage displayed.

Nginx still needs to be configured in /etc/nginx/sites-enabled/default. The server name must be changed here to include matabit.org, www.matabit.org, and blog.matabit.org. This will allow the user to connect to the server by typing any of those URLs.