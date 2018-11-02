---
title: "Anthony Week 10"
date: 2018-11-01T15:57:16-07:00
draft: false
layout: 'posts'
---
This weeks focus was implementing the design we created in project 4. This met actually hosting our blog using an S3 bucket and CloudFront. My task were to focus on CircleCI and Cloudfront

## CircleCI
My task for this project was to reconfigure CircleCI to deploy into an S3 bucket. This is was simple change in the yaml file that was create in the previous that would compress the `public`/ directory. The build-test pipeline stayed the same but the deploy was altered to push the `public/` directory into a public S3 bucket

```yaml
- deploy:
    name: deploy to AWS
    command: |
     if [ "${CIRCLE_BRANCH}" = "master" ]; then
        aws s3 sync $HUGO_BUILD_DIR \
        s3://matabit.org --delete
    else
        echo "Not master branch, dry run only"
    fi
```

## Cloudfront
Cloudfront is a CDN service by Amazon. The CDN will have a source origin from the public S3 bucket. We will also attached a custom ACM to the CDN to serve our content over SSL. The CDN itself takes awhile to propagate even when you invalidate and object, so the blog won't instantly deploy. Our Route53 A records are pointed to the CDN Domain name. 

```json
resource "aws_cloudfront_distribution" "matabit_distribution" {
  origin {
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    domain_name = "${data.terraform_remote_state.s3.matabit-web-endpoint}"
    origin_id   = "matabit.org"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "matabit.org"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31546000

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  aliases = ["matabit.org","www.matabit.org","blog.matabit.org"]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${data.terraform_remote_state.cert.cert-arn}"
    ssl_support_method  = "sni-only"
  }
}
```
