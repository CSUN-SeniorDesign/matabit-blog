---
title: "Anthony Week 6"
date: 2018-10-04T22:51:27-07:00
layouts: 'posts'
draft: false
---
# Week 6
For my tasks week 6, I had to reconfigure CircleCI to properly put object into the S3 bucket. I also had to play around with the IAM roles and policies to get the permissions just right to work on the S3 bucket. Finally, I worked on the site deployment by creating a bash script on a cronjob that was eventually built into the packer AMI.

## IAM roles
Over the weekend I was testing out the IAM roles for putting objects into the S3 bucket via CircleCI. I ran into issues due to improper configurations on the IAM policy but I eventually got it correct after trial and error. For CircleCI, I created a circleci user that was added to a circle group. This group had a policy attached to it that allowed the to put object into the S3 bucket. Next IAM task was creating a role for the EC2 buckets. This role allowed the EC2 to get objects from the S3 bucket. For this, I create a role, added the role to an instance profile (for the EC2), and attached the policy to the instance profile. This IAM instance profile was then shared the the ASG to allow the EC2 launch instances to get objects from the S3 bucket. 

## CircleCI reconfiguration
I had to reconfigure CircleCI to also deploy into the staging and master folders of the bucket. I did this with pipelines/workflows. First I had a build workflow which as basically stages within the CI/CD pipeline. Originally I had a build and test pipeline but I condensed them into one job because it was redundant to build the project twice. Next I had a pipeline that would always deploy into the staging S3 bucket whenever a commit/merge is made into master. I also had one set for the master S3 bucket folder that would deploy on approval in the CircleCI interface. The deploy step looks like this:

```bash
if [ "${CIRCLE_BRANCH}" = "master" ]; then
              tar -zcvf /hugo/${CIRCLE_SHA1}.tar.gz -C $HUGO_BUILD_DIR .
              aws s3 cp /hugo/${CIRCLE_SHA1}.tar.gz \
              $MASTER_BUCKET${CIRCLE_SHA1}.tar.gz
            else
              echo "Not master branch, dry run only"
            fi
```

## Creating a deploy script
Next I had to create a bash script that would check the S3 bucket for any changes. If there was a change, it'll grab the latest `$SHA1-commit.tar.gz` file and pull it into the EC2. Once on the EC2 it will unzip and deploy into the respect web directories for staging and master. I wrote this in a bash script that would eventually run on a cronjob every 5 minutes. This was then implemented in a custom AMI built using packer. I had a small issue with the cronjob initially because I didn't have a $PATH set of the cronjob, this didn't allow the script to have access to the `aws` command. I added the $PATH in the script and everything worked beautifully. Here's the script below:

```bash
```bash
#!/bin/bash

export PATH=${PATH}:/usr/local/bin
# S3 Bucket
BUCKET=s3://matabit-circleci

# Staging variables
STAGING_LATEST=`aws s3 ls $BUCKET/staging/ | sort | tail -n 1 | awk '{print $4}'`
STAGING_FILE_PATH=/tmp/staging/ #Change to /tmp/path
CHECK_STAGING=`ls $STAGING_FILE_PATH`
STAGING_PATH='/var/www/staging/matabit-blog/public/'

# Master variables
MASTER_LATEST=`aws s3 ls $BUCKET/master/ | sort | tail -n 1 | awk '{print $4}'`
MASTER_FILE_PATH=/tmp/master/ #Change to /tmp/path
CHECK_MASTER=`ls $MASTER_FILE_PATH`
MASTER_PATH='/var/www/prod/matabit-blog/public/'

check_staging () {
  if [ "$CHECK_STAGING" != "$STAGING_LATEST" ]; then
    echo "Staging: New update found, deploying now"
    # Get latest tar file
    aws s3 cp $BUCKET/staging/$STAGING_LATEST $STAGING_FILE_PATH/$STAGING_LATEST
    # Unzip into /var/www (For future use) 
    mkdir -p $STAGING_PATH && tar -xzf $STAGING_FILE_PATH/$STAGING_LATEST -C $_
    # Removed outdated tar files
    find $STAGING_FILE_PATH -type f \! -name "*$STAGING_LATEST*" -delete
    # Set web directory permission and gracefully restart nginx
    web_permission
    nginx_graceful_restart
  else
   echo "Staging: No updates found"
  fi
}

check_master() {
if [ "$CHECK_MASTER" != "$MASTER_LATEST" ]; then
    echo "Master: New update found, deploying now"
    # Get latest tar file
    aws s3 cp $BUCKET/master/$MASTER_LATEST $MASTER_FILE_PATH/$MASTER_LATEST
    #Unzip into /var/www (For future use) 
    mkdir -p $MASTER_PATH && tar -xzf $MASTER_FILE_PATH/$MASTER_LATEST -C $_
    # Possibly remove tar file?
    find $MASTER_FILE_PATH -type f \! -name "*$MASTER_LATEST*" -delete
    # Set web directory permission and gracefully restart nginx
    web_permission
    nginx_graceful_restart
  else
    echo "Master: No new updates"
  fi
}

web_permission() {
  chown -hR www-data:www-data /var/www/
}

nginx_graceful_restart() {
  nginx -s reload
}

check_staging
check_master
```

```
