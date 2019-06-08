resource "aws_api_gateway_rest_api" "api" {
  name        = "Website - Email"
  description = "Captação de Emails"
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id       = "${aws_api_gateway_rest_api.api.id}"
  stage_name        = "prod"
  stage_description = "${md5(file("api.tf"))}"             #Forçar atualização do stage
}

module "website_email" {
  source      = "github.com/fernandoruaro/serverless.tf//api_gateway/resource"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = "email"
}

module "website_email_ANY" {
  source              = "github.com/fernandoruaro/serverless.tf//api_gateway/method/lambda"
  rest_api_id         = "${aws_api_gateway_rest_api.api.id}"
  resource_id         = "${module.website_email.id}"
  http_request_method = "ANY"
  lambda_invoke_arn   = "${module.lambda_website_email.lambda_invoke_arn}"
}
