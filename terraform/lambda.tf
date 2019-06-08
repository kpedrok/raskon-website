# module "lambda_raskon_quotation" {
#   source        = "github.com/fernandoruaro/serverless.tf//lambda/api_gateway"
#   path          = "../quotation-final/"
#   handler       = "quotation-final.lambda_handler"
#   function_name = "raskon-quotation-coverage"
#   runtime       = "python3.7"
#   timeout       = "15"
#   memory_size   = "512"

module "lambda_website_email" {
  source        = "github.com/fernandoruaro/serverless.tf//lambda/api_gateway"
  path          = "../api/website-email/"
  handler       = "website-email.lambda_handler"
  function_name = "${local.prefix_dash}website-email"
  runtime       = "python3.7"
  timeout       = 300

  # variables = "${local.variables}"

  extra_policy_statements = [<<EOF
{
  "Effect": "Allow",
  "Action": "dynamodb:*",
  "Resource": "*"
},
{
  "Effect": "Allow",
  "Action": "ses:*",
  "Resource": "*"
}
EOF
  ]
}
