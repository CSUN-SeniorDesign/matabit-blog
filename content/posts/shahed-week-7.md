---
title: "Shahed Week 7"
date: 2018-10-12T13:57:14-07:00
draft: false
layout: 'posts'
---

# Docker And CircleCI

Since this week it was about containerizing our applications, I was tasked with configuring Docker and CircleCI.

## Docker

One of our goals for this weeks project was to create a Docker image that is as lightweight as possible.

One of the lightest distributions is Alpine Linux.
It is as barebones as possible with it's 4MB's in size.

Docker Hub already had an image of Alpine with nginx preinstalled. To save time and effort, we decided to go with that image as a baseline and then built our blog upon that.

```Docker
# nginx image built on top of alpine linux
FROM nginx:alpine
```

To allow for different build environments from the same docker file, we decided to go would with `ARG` Option, which allows us to give environment variables through the command-line with the `--build-arg` option.

```Docker
 ARG BUILD_VAR
```


To create the root web directories for the different environments, we used the `RUN` Docker command which enables us to run shell commands directly. Since every `RUN` Command adds weight and complexity to the Docker image, we decided to stick with one `RUN` command but instead chain shell commands with `&&`.

```Docker
 # Create environment folders and copy index file for test
RUN mkdir -p "/var/www/staging/matabit-blog/public" \
    && mkdir -p "/var/www/prod/matabit-blog/public" \
    && cp /usr/share/nginx/html/index.html \
       /var/www/prod/matabit-blog/public \
    && cp /usr/share/nginx/html/index.html \
        /var/www/staging/matabit-blog/public
```

After we've established all the necessary folders, we use the `BUILD_VAR` argument to copy the public directory to the correct folder.

```Docker
 # Copy content of public folder to docker image
COPY public /var/www/$BUILD_VAR/matabit-blog/public
```

Since we need our NGINX Config to be on the docker image as well, we created a separate file that will reside in the repository and we will copy that template file into the `default.conf` file that nginx has by default.
```Docker
 # add custom nginx config
COPY nginx.template /etc/nginx/conf.d/default.conf
```

Last but not least, we expose `PORT 80` for the docker image, so that traffic can flow to the container.
```Docker
 # expose port 80 for HTTP
EXPOSE 80
```


## CircleCI

CircleCI helps us build a CI/CD pipeline with Docker images.
CircleCI itself runs on docker images to run the tests and build the applications. 

We have three jobs defined.
`build-test`, `deploy-staging`, `deploy-master`.


### build-test
```YML
 build-test:
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
            htmlproofer $HUGO_BUILD_DIR
```    
This has remained the same from the last project. it uses the cibuilds/hugo Docker image to test and build the blog.


### deploy-staging
```YAML
deploy-staging:
    docker:
      - image: ssalehian/circleci-aws-docker:latest
    working_directory: /hugo
    environment:
      HUGO_BUILD_DIR: /hugo/public
      BUILD_ENV: staging
    steps:
      - checkout
      - setup_remote_docker
      - run: git submodule sync && git submodule update --init
      - run: HUGO_ENV=production hugo -v -d $HUGO_BUILD_DIR
      - run: ls -la $HUGO_BUILD_DIR
      - run: ls -la /hugo
      - deploy:
          name: Create Docker Image and push to ECR
          command: |
            $(aws ecr get-login --no-include-email --region us-west-2)
            docker build -t matabit-blog-staging --build-arg BUILD_VAR=$BUILD_ENV .
            docker tag matabit-blog-staging:latest 485876055632.dkr.ecr.us-west-2.amazonaws.com/matabit-ecr:staging
            docker push 485876055632.dkr.ecr.us-west-2.amazonaws.com/matabit-ecr:staging
            touch ${CIRCLE_SHA1}.txt
            aws s3 cp ${CIRCLE_SHA1}.txt $DOCKER_BUCKET_STAGING${CIRCLE_SHA1}.txt
```

Here we had to develop a separate Docker image, which includes the `awscli`, `hugo` and `docker` so that we can build a Docker image within that Docker image to push to the ECR. This requires the ECR to already be established otherwise it doesn't work.

For future Lambda Triggers, we ensure that a .txt file with the `CIRCLE_SHA1` is being pushed to an S3 Bucket that the lambda function can then read. So everytime we create a new Docker image and that image gets pushed to the ECR, it will trigger a Lambda function to pull the new Docker image into the ECS.

### deploy-master

Deploy to production follows the same workflow as staging, however, it requires manual approval, and knows which environment to run in the command-line based on the $BUILD_ENV variable defined in the environment block.

