module "lambda_website_email" {
  source        = "github.com/fernandoruaro/serverless.tf//lambda/api_gateway"
  path          = "../src/api/website-email/"
  handler       = "website-email.lambda_handler"
  function_name = "${local.prefix_dash}website-email"
  runtime       = "python3.7"
  timeout       = 300

  # variables = "${local.variables}"

  extra_policy_statements = [<<EOF
{
  "Effect": "Allow",
  "Action": "ses:*",
  "Resource": "*"
}
EOF
  ]
}
