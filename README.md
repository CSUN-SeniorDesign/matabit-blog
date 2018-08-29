# matabit-blog
Matabit blog repo

## How to get started
Clone the repo with ``git clone git@github.com:CSUN-SeniorDesign/matabit-blog.git``

Change directory into the theme/hyde-hyde folder

Init and update the submodule by running ``git submodule init; git submodule update``

## Creating new pages
In order to create a new blog post run ``hugo new posts/[name-of-your-post].md`` and edit the front matter similar to the example

```yaml
---
title: "Anthony Week-1"
date: 2018-08-28T23:15:05-07:00
layout: 'posts'
draft: false
---
```

After you've made your post run ``hugo`` in the root directory to generate the page
