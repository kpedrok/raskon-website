resource "aws_api_gateway_rest_api" "api" {
  name        = "${local.prefix_dash}api"
  description = "Captação de Emails"
}

// This blocks adds a domain name, so your API adress will look clean and professional
resource "aws_api_gateway_domain_name" "domain_name" {
  domain_name     = "api.raspro.com.br"
  certificate_arn = "${aws_acm_certificate.certificate.arn}"
}

resource "aws_api_gateway_base_path_mapping" "mapping" {
  api_id      = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "${aws_api_gateway_deployment.deployment.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.domain_name.domain_name}"
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id       = "${aws_api_gateway_rest_api.api.id}"
  stage_name        = "prod"
  stage_description = "${md5(file("api.tf"))}"             //Forces stage update
}

//Beyond here every two block is a API

module "website_email" {
  source      = "github.com/fernandoruaro/serverless.tf//api_gateway/resource"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = "website_email"
}

module "website_email_ANY" {
  source              = "github.com/fernandoruaro/serverless.tf//api_gateway/method/lambda"
  rest_api_id         = "${aws_api_gateway_rest_api.api.id}"
  resource_id         = "${module.website_email.id}"
  http_request_method = "ANY"
  lambda_invoke_arn   = "${module.lambda_website_email.lambda_invoke_arn}"
}
