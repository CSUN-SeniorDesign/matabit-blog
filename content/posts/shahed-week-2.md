---
title: "Shahed Week 2"
date: 2018-09-04T18:47:29-07:00
layout: 'posts'
draft: false
---

# How We Obtained Our TLS/SSL Certificates

## What We Need To Do
We were tasked to obtain a TLS certificate for the following domains

```
matabit.org
www.matabit.org
blog.matabit.org
```

To simplify the process for these and any future domains, we need to obtain a wildcard certificate.

## Where We Get The Certificate
The certificate authority that we use is [Let's Encrypt](https://letsencrypt.org/).
To request these certificates on our AWS EC2 instance, we use [Certbot](https://certbot.eff.org/lets-encrypt/ubuntuxenial-nginx).

## To install Certbot run the following commands:

```
$ sudo apt-get update
$ sudo apt-get install software-properties-common
$ sudo add-apt-repository ppa:certbot/certbot
$ sudo apt-get update
$ sudo apt-get install python-certbot-nginx
```

This installs all the necessary dependencies to run certbot on the server and request the certificates.

## Problems We Encountered
The first problem we encountered was thinking that a single wildcard ceritficate would cover the apex domain in addition to any subdomains. So anytime we would visit the blog through the apex domain HTTPS wouldn't work.

To fix that, we tried implementing a second SSL certificate and it worked but at a second glance at the requirements we found out that we can only use a single certificate to cover the wildcard domains and the apex domain.

So we found out about SubjectAltNames which allows us to add multiple domains to a single certificate.

Finally we managed to request the correct certificate by running the following command
```
$ sudo certbot certonly --manual -d *.matabit.org -d matabit.org -m dev@anthonyinlavong.com --preferred-challenges dns-01 --server https://acme-v02.api.letsencrypt.org/directory
```

## Configure NGINX
To have NGINX use the SSL certificates we have to include them in the correct server-blocks with the following syntax:
```
ssl_certificate /etc/letsencrypt/live/matabit.org/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/matabit.org/privkey.pem;
```