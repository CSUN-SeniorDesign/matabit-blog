---
title: "Anthony Week 2"
date: 2018-09-06T20:17:58-07:00
layout: 'posts'
draft: false
---

# Week 2
During week two, my main focus for the project was updating [documentation](https://github.com/CSUN-SeniorDesign/matabit-infrastructure) to reflect the standard procedures for installing, running, and deploying hugo. A majority of the work the infustructure was done during week 1, you can visit my previous blog post to view the first week about installing Hugo. Week 1 was over, so we had blog post that were ready to be deployed into our EC2.

## Deploying blog post
For deploying the blog we we're given only one requirement. We couldn't use git clone on our production server. At first glance it seemed unorthodox due to previous experience for other group members and I. In order for to deploy our webpage we had to zip/tar our web pages, transfer it over to our EC2, and uncompressed our web pages into the Nginx web root. For our case, this would be located in the `/var/www/matabit-blog/public` directory. Doing this manually would be tedious, so I opted to create a bash script that would handle deployments. Below is the bash script.

```bash
#!/bin/bash 
printf "============================\n"
printf "Running hugo to build blog pages \n"
printf "============================\n"
hugo 
echo
printf "============================\n"
printf "Blog built \n"
printf "============================\n"
echo
printf "============================\n"
printf "Deploying to EC2 instance\n"
printf "============================\n"
echo
zip -r public.zip public/ 
rsync -azP public.zip ubuntu@matabit.org:/home/ubuntu/hugo/
echo
ssh ubuntu@matabit.org << EOF
  sudo unzip -o hugo/public.zip -d /var/www/matabit-blog
  sudo chown -hR www-data:www-data /var/www/matabit-blog
EOF
echo
printf "============================\n"
printf "Blog has been deployed\n" 
printf "============================\n"
echo
```
To break down the script (*Note this only works if you have access to the EC2*):

  * In order to run the scipt give it execute permissions with `chmod +x deploy.sh`. Now you can run the script with `./deploy.sh`
  * Run `hugo` to build the site into the `public/` directory
  * Zip the contents for the public directory into a public.zip file
  * Transfer the zip file via `rsync`
  * SSH into the EC2 instance
  * Unzip the transfer zip file into the Nginx web root
  * Change group/user of the extracted directory to www-data. This is a safe measure just in case of permission issues.
