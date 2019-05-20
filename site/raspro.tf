locals {
  raspro_domain="raspro.com.br"
}

data "aws_route53_zone" "domain" {
  name = "${local.raspro_domain}"
}

resource "aws_acm_certificate" "raspro_wildcard_certificate" {
  domain_name               = "*.${data.aws_route53_zone.domain.name}"
  subject_alternative_names = ["${data.aws_route53_zone.domain.name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "raspro_wildcard_certificate" {
  name    = "${aws_acm_certificate.raspro_wildcard_certificate.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.raspro_wildcard_certificate.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.domain.zone_id}"
  records = ["${aws_acm_certificate.raspro_wildcard_certificate.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "raspro_wildcard_certificate" {
  certificate_arn         = "${aws_acm_certificate.raspro_wildcard_certificate.arn}"
  validation_record_fqdns = ["${aws_route53_record.raspro_wildcard_certificate.fqdn}"]
}



resource "aws_cloudfront_distribution" "raspro_cdn" {
  origin {
    domain_name = "${aws_s3_bucket.site.bucket_domain_name}"
    origin_id   = "s3"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = ["${local.raspro_domain}", "www.${local.raspro_domain}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  ordered_cache_behavior {
    path_pattern     = "*.html"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 60
    max_ttl                = 300
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate.raspro_wildcard_certificate.arn}"
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}


resource "aws_route53_record" "site_root" {
  zone_id = "${data.aws_route53_zone.domain.zone_id}"
  name    = "${data.aws_route53_zone.domain.name}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.raspro_cdn.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.raspro_cdn.hosted_zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "site_www" {
  zone_id = "${data.aws_route53_zone.domain.zone_id}"
  name    = "www.${data.aws_route53_zone.domain.name}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.raspro_cdn.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.raspro_cdn.hosted_zone_id}"
    evaluate_target_health = true
  }
}