---
title: "Anthony Week 7"
date: 2018-10-12T17:24:07-07:00
layouts: 'posts'
draft: false
---
# Week 7
This weeks project dealt with transitioning our infrastructure over to ECS. I'm not a stranger to docker or containerization but deploying them into production was alien to me, so this would be an interesting project. My main task this week was creating a lambda script to replace the bash script from the previous project. I also aided in creating the ECS but ran into issues on configuration. 

## Lambda function
Originally, I wanted to write the Lambda function in Go so I could get some experience with it. I ended up however using good old Python 3 because of the time constraint of the project. I've had previous experience using Lambda and creating functions in Python so I was familiar with the workflow. For the trigger, I read a specific S3 object made from CircleCI for PUT changes. If there were change, the Lambda function will trigger to update the cluster's respective service (Production/Staging). I've create the script locally so I can test to run. I've added boto3, Amazon's python3 SDK which is used to interact with AWS resources. Basically via aws-cli. A sample of the code below.

```python
import boto3 

client = boto3.client('ecs')


response = client.update_service(
    cluster='anthony-test',
    service='anthony-service',
    desiredCount=1,
    taskDefinition='anthony-task-test',
    deploymentConfiguration={
        'maximumPercent': 200,
        'minimumHealthyPercent': 100
    },
    networkConfiguration={
        'awsvpcConfiguration': {
            'subnets': [
                'subnet-0fb75c1b6051a2462',
            ],
            'securityGroups': [
                'sg-0669b8083b6346e37',
            ],
            'assignPublicIp': 'ENABLED'
        }
    },
    platformVersion='LATEST',
    forceNewDeployment=True,
    healthCheckGracePeriodSeconds=60
)
```

## What's next?
I have to deploy the Lambda Function using Terraform, so that'll take a few hours. My main concern is setting up the ECS. Shahed and I are going back and forth trying to get this infrastructure to fully work. We're currently using the console to configure this, so it'll take some time to refactor into Terraform code. Our current issue is the ALB and the ECS, both are somewhat talking but the sites are not fully functional. After the ECS has been fully hashed out, we are basically 95% done with the project. 
