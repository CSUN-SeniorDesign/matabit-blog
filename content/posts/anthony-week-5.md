---
title: "Anthony Week 5"
date: 2018-09-28T09:19:29-07:00
layouts: 'posts'
draft: false
---
# Week 5 tasks
For my tasks this Week I had to set up and configure CircleCI, a tool for CI/CD. I've had experience using Gitlab's CI/CD along with TravicCI. From the start they were very similar it terms of supporting docker out of the box for building and test, which is great.

## CirclCI configuration
First, CircleCI must be enabled on the Github repo. This is done via the marketplace but since we are under and organization we must wait on an admin to enable it. After it's been enabled, we must add `.circleci/config.yml`. This file still executes specific commands under CircleCI to handle all the CI/CD. 

## Basic config structure
The file is in YAML format so spacing and syntax are important. I had an issue where the yml file would not run because of an extra space, it's always the little things. The `version` is set for CircleCI. Jobs are the various commands and set up for testing and building your project. Build is the name of the job, note the spacing. Docker is specifying the docker image for the project. The working directory and environment tags are variables for the project. Steps are the commands associated to testing/building. 


```yaml
version: 2
jobs:
  build:
    docker:
    working_directory:
    environment:
    steps:
```
## Testing and building
For now, I got to the point of testing and building the blog. I haven't moved on to the deployment part because I'm waiting on the IAM account. The IAM account will allow CircleCI to place a tar’ed version of the blog into an S3 bucket for later deployment. Testing the blog currently fails because the theme is missing a `<li>` elements for some weird reason. Below is the configuration for CircleCI. 

```yaml
version: 2
jobs:
  build:
    docker:
      - image: cibuilds/hugo:latest
    working_directory: /hugo
    environment:
      HUGO_BUILD_DIR: /hugo/public
    steps:
      - run: apk update && apk add git
      - checkout
      - run: git submodule sync && git submodule update --init
      - run: HUGO_ENV=production hugo -v -d $HUGO_BUILD_DIR
  test:
    docker:
      - image: cibuilds/hugo:latest
    working_directory: /hugo
    environment:
      HUGO_BUILD_DIR: /hugo/public
    steps:
      - run: apk update && apk add git
      - checkout
      - run: git submodule sync && git submodule update --init
      - run: HUGO_ENV=production hugo -v -d $HUGO_BUILD_DIR
      - run: ls -la $HUGO_BUILD_DIR
      - run:
          name: "Test for HTML files"
          command: |
            htmlproofer $HUGO_BUILD_DIR --allow-hash-href --check-html \
            --empty-alt-ignore --disable-external    
```
