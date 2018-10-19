---
title: "Anthony Week 8"
date: 2018-10-17T22:01:36-07:00
draft: false
layouts: "posts"
---
# Week 8
This week's focus was implementing the Lambda script with Terraform and actually getting it to work. There were a few roadblocks along the way but they were eventually ironed out in the end. 

## Testing the Lambda script
For testing the Lambda function, I simply ran the Python script on my local machine. It ended up working locally but I had to figure out the correct formatting and handler to use in AWS. When loading the Lambda script into Terraform I had to be specific in terms of file names and and handlers. If something was off, the function would not work and error out. When the function was working I read the CloudWatch logs to see any errors and the status of the script. Looking at the Cloudwatch logs also gave me insight to when the Lambda function would fire off.

## The Lambda function
The Lambda script is the same, but it's separated into two functions: one for staging and one for production. I could have made it efficient by condensing it to one function with filters while listening to event, but ended up with this methodology. The script itself uses the boto3 Python library for the AWS SDK. I only used the update_service function to forcefully provision the task definitions in the service, this made it use the latest image on the ECR for production/staging. A sample of the function is found here:
```python
import boto3
from pprint import pprint
client = boto3.client('ecs')

def main(event, context):
    response = client.update_service(
        cluster='matabit-cluster',
        service='matabit-staging-service',
        desiredCount=2,
        taskDefinition='matabit-staging',
        deploymentConfiguration={
            'maximumPercent': 200,
            'minimumHealthyPercent': 100
        },
        platformVersion='LATEST',
        forceNewDeployment=True,
        healthCheckGracePeriodSeconds=60
    )
```

## Deploying the Lambda Function
To deploy the Lambda function I first had to create an IAM role and policy specifically for the Lambda Role to execute. For the sake of this project I openly many of the permissions. The policy were basically "allow" statements for the various AWS functions and resouces the Lambda function will touch.

After I set IAM role I moved on to uploading the Lambda function via Terraform which looks like this:
```
resource "aws_lambda_function" "update-service-lambda-staging" {
  filename         = "lambda-staging.zip"
  function_name    = "update-ecs-service-staging"
  role             = "${aws_iam_role.lambda-ecs-role.arn}"
  handler          = "update-ecs-staging.main"
  source_code_hash = "${base64sha256(file("lambda-staging.zip"))}"
  runtime          = "python3.6"
}
```
After, I allows the Lambda to use the S3 bucket resource and created the triggers for the Lambda to fire off. It triggers once there is an object put into either the staging/master folder which is created by CircleCI

```
resource "aws_lambda_permission" "allow_bucket-staging" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.update-service-lambda-staging.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${var.circle-ci-bucket-arn}"
}

resource "aws_s3_bucket_notification" "s3-bucket-notification" {
  bucket = "${var.circle-ci-bucket-id}"
  lambda_function{
    lambda_function_arn = "${aws_lambda_function.update-service-lambda-prod.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "docker-prod/"
    filter_suffix       = ".txt"
  }

  lambda_function{
    lambda_function_arn = "${aws_lambda_function.update-service-lambda-staging.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "docker-staging/"
    filter_suffix       = ".txt"
  }
}
```

## Overall
With this process the Lambda script is triggers by an S3 event. Once triggered it will update the ECS Cluster's service. I had difficulties with Terraform and Lambda but were ironed out. I wish I had more time, I would have condensed the function into one script that would read an S3 event to either grab staging or master. 
