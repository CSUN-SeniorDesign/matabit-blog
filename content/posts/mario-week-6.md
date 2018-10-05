---
title: "Mario Week 6"
date: 2018-10-04T22:42:37-07:00
layout: 'posts'
draft: false
---

# Week 6 Blog

For week 6, I had to work on finishing up DataDog and the configuration files for it. As well as work on writing the doc for DataDog and preparing for the presentation. 

## DataDog

For DataDog my task was too track specific information and metrics about our website such as 
CPU usage, CPU load averages (1 minutes, 5 minute, 15 minute), Memory usage by the system, Disk usage on the system, and Process uptime.

This was simple to do as the metrics were already built into DataDog itself and no additional steps were needed to provide these metrics of our website. 

Additional metrics we had to track about our website are: The number of requests to your website, The latency for requests to your website, and Status codes of requests to your server (2xx, 3xx, 4xx, 5xx). 

In order to track these metrics custom config files had to be created in order for them to show up on DataDog and present them on the dashboard. 

My issue here was having trouble on where to create these custom config files and the correct ansible syntax in order for the config file to function properly. With the help from my team members I was able to understand where to create the config files and the correct syntax to use to get them working on DataDog. 

The custom config files look as so: 

#### http_check.yaml

```
init_config:
  # Change default path of trusted certificates
  # ca_certs: /etc/ssl/certs/ca-certificates.crt

instances:
  - name: My staging env
    url: https://staging.matabit.org
  
  - name: My prod env
    url: https://matabit.org

    timeout: 1

    # The (optional) http_response_status_code parameter will instruct the check
    # to look for a particular HTTP response status code or a Regex identifying
    # a set of possible status codes.
    # The check will report as DOWN if status code returned differs.
    # This defaults to 1xx, 2xx and 3xx HTTP status code: (1|2|3)\d\d.
    http_response_status_code: (2|3|4|5)\d\d

    # The (optional) collect_response_time parameter will instruct the
    # check to create a metric 'network.http.response_time', tagged with
    # the url, reporting the response time in seconds.
    
    # The latency for requests to the website
    collect_response_time: true
```

#### nginx.yaml

```
init_config:
  # Change default path of trusted certificates
  # ca_certs: /etc/ssl/certs/ca-certificates.crt

instances:
  # Check for nubmer of requests to the website
  - nginx_status_url: http://localhost:81/nginx_status/
```

#### ssh_check.yaml

```
init_config:

instances:
  - host: 127.0.0.1 # required
    username: root # required
    password: <SOME_PASSWORD> # or use private_key_file

```

### What’s Next? 

For next week, we will be assigned project 3 to work on. The professor mentioned the next project will have to do with images to containers. So I will be reading and studying up on working with The Docker Flow: Images to Containers in order to prepare for the next project. 