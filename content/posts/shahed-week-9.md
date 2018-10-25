---
title: "Shahed Week 9"
date: 2018-10-24T15:51:45-07:00
draft: false
layout: 'posts'
---

# Group Presentations and Cost Calculator

## Which group should we join...

Lecture time this week was mostly spent listening to Senior Design project pitches and the one that stood out the most to me was the one project with the Estate Planning attorney. It would give us an opportunity to help design a project from scratch and really make key decisions as to how to design a product and what measures would be best without having to refactor and redesign a old product and having to fight with compatibility issues.

However, the CSUN Student Academic Progression system is also a very interesting project in the sense that it would give us the most real world experience as we would have to help maintain and add features to a current existing system. It is rare that we would get to design a system from scratch so that would also be a very valuable experience.


## Cost Calculator

Looking at the cost calculator, I noticed that it was missing calculations for Elastic Container Services.

Since we only need to calculate traffic to one page and one environment, we looked into a t2.nano instance. Having that instance with SSL would cost us about $4-5/month.

The cheapest option, as we've found out, is actually deploying the blog in a S3 bucket and delivering it with a CDN via AWS CloudFront. Route53 can point to CloudFront and then serve the static-page blog through that, without the overhead of an OS and would cost us as little as $0.04-$0.05/month! 
We calculated that on a the basis that we're only going to need 1000 GET Requests per month.




