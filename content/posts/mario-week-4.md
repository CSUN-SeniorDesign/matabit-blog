---
title: "Mario Week 4"
date: 2018-09-20T21:35:55-07:00
layout: 'posts'
draft: false
---

# Ansible, Documentation, and Presentation

Week 4 involved working on the last part of the project which was to setup and configure a webserver using ansible, documentation for the tasks I was assigned which was setting up Route 53 using Terraform, and prepare the slides for our presentation. 

## Ansible

For ansible I was tasked with setting up and configuring a web server. For this task we first agreed on using Nginx as our webserver. The reason we chose Nginx is because it is the fastest web server around and consistently beats Apache and other servers in measuring web server performance. 

#### Ansible Issues

Some issues I faced setting up the webserver were not knowing where to place the file, how to run the playbook, and the markup ansible uses as I was still getting to know how to use ansible. With the help of my team members, I was able to figure out these issues to  understand how the webserver was setup and what it means. 

Also I was shown how to run the playbook as so:

```
ansible-playbook main.yml
```

As well as how to install and run the project: 

```
- name: Install and deploy project1
  vars:
    ansible_python_interpreter: /usr/bin/python3
  hosts: all
  roles: 
    - update-cache
    - nginx-hugo
    - hugo
```


The Nginx Setup looks as follows:

```
- name: Install Nginx and Dependencies
    become: true
    apt:
      name: "{{ item }}"
      state: present
    with_items:
      - nginx
      - unzip
      - zip
      
  - name: Change Nginx default site settings
    become: true
    template:
      src: default
      dest: /etc/nginx/sites-available/default
  
  - name: Restart nginx
    become: true
    service: 
      name: nginx 
      state: restarted
```

## What's Next?

For next week we have the presentation to do on monday for project 1. Since project 2 has not been posted yet, my goal is to familiarize myself more with terraform and ansible as I am sure we will be using both tools more in depth for our following projects. 

