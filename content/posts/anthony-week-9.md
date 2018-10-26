---
title: "Anthony Week 9"
date: 2018-10-26T09:17:20-07:00
draft: false
layout: 'posts'
---
# Group presentations and web hosting research

## Hosting the Matabit blog
This week was more more focused on design and planning rather than implementation. The goal for this week was to find the cheapest possible way to host our blog on AWS infrastructure. The requirement is to not use AWS free tier services or at-least pretend our free tier is expired. Also we had to add an SSL cert to our site and server only production. I've had previous experience hosting my own blog on AWS infrastructure using an S3 bucket, Cloudfront, and pointing my DNS records to Cloudfront. This costed me a few pennies a month but I have since moved my blog to [Netlify](https://www.netlify.com/) due to free SSL and hosting. 

## Senior design group project selection
We also had the Comp Sci Senior Design group join us a people pitched projects we can work on for the rest of the class. It was done a bit differently this year, instead of students creating projects we had clients outside pitch projects. Some were new clients with an idea while others were already built and needed additional work done. 

The projects that caught my interest were: the lawyer forms, class navigation project, then the Academic Progression project. I am somewhat bias towards the class due to the apis already being created and the framework requiring Laravel, which I am highly familiar with. Next would be the forms project because we basically have free reign over the infrastructure on the ops side. The Academic Progression project has a weary because it's written in .NET which I am not familiar with, plus the project itself seemed rushed from beginning so there will be a-lot of refactoring. 

