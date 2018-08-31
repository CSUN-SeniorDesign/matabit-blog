---
title: "Anthony Week 1"
date: 2018-08-28T23:15:05-07:00
layout: 'posts'
draft: false
---
Tasks:

* Create Hugo site
* Buy a domain

## What's Hugo?
Hugo is a static site generate built with the Go programming language. A static site generator takes files written in markdown and builds them into working web pages, html and css included. They're many other static site generators such as [Jekyll](https://jekyllrb.com/) and [VuePress](https://vuepress.vuejs.org/). 

### How to get started
In order to run the Hugo, you will need the binary file. OSX has a package manager called Homebrew which simplifies the installation of Hugo. Windows also has a similar package manager called choco. On the Ubuntu side, it's recommended to install it via snap due to the outdated debian repo. On RHEL/Centos/Fedora you can use the dnf package manager to install it. After installing the binary run `hugo version` to make sure it installed correctly with the latest version of V0.48.

To install Hugo on OSX run `brew install hugo` in the terminal

To install Hugo on Windows run `choco install hugo`

On Ubuntu run `sudo snap install hugo --channel=extended`

After verifying Hugo was installed, create the boilerplate for the blog using `hugo new site matabit-blog` and add it to the git repo. Replace *matabit-blog* with the name of your project.

### Adding themes
Hugo has a plethora of themes to choose from at their [theme gallery](https://themes.gohugo.io/). In this project we selected [hyde-hyde](https://github.com/htr3n/hyde-hyde). Install the theme as a submodule using:

`git submodule add https://github.com/htr3n/hyde-hyde.git themes/hyde-hyde`

****Note on a freshly cloned project you must init and update the submodule, do this inside the theme/hyde-hyde directory using the command: `git submodule init; git submodule update`**

The next step is to configure the `config.toml` file accordingly. More info on the hyde-hyde [git repo](https://github.com/htr3n/hyde-hyde) or take a look at our own [toml](https://github.com/CSUN-SeniorDesign/matabit-blog/blob/master/config.toml) file

### Create a new blog post
Creating a blog post is simple. Just run `hugo new blog posts/[you-post-name].md`, this will generate a markdown file in `content/posts/` with the default front-matter. Be sure to set draft to false and insert the layout as `layout: posts` in the front-matter when the post is ready to be published. 

### Serving and publishing
Serving the hugo site will allow you to see a local version of the site, live reloading included. Do this by running `hugo serve` in the hugo project's root directory. Building a hugo site will process the markdown into HTML/CSS into a `public/` directory. Run `hugo` to build the pages. From here you can point a web server to the `public/` directory to display the site. 

### Purchasing the domain
Purchasing a domain is simple enough. We used [Namecheap](https://namecheap.com) to purchase our domain and opted out of purchasing a SSL cert as we will be using [Let's Encrypt](https://letsencrypt.org/) to generate our SSL cert. 