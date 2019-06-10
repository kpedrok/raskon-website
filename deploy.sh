# https://medium.com/runatlantis/hosting-our-static-site-over-ssl-with-s3-acm-cloudfront-and-terraform-513b799aec0f

rm terraform/.terraform/terraform.tfstate
aws s3 ls
(cd terraform
    terraform init -input=false 
    terraform plan -out=tfplan
    terraform apply tfplan
    rm tfplan)

# aws s3 sync V3/site s3://`(cd terraform; terraform output site_bucket)`
aws s3 sync src/site s3://www.raspro.com.br
# aws s3 sync site s3://`(cd terraform; terraform site www_domain_name)`


# cd -
# cd terraform


# terraform state show aws_s3_bucket.www | grep website_endpoint
# terraform state show aws_route53_zone.zone

