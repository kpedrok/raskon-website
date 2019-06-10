variable "region" {
  default = "us-east-1"
}

locals {
  #   prefix_dash = "${var.project}-${var.env}-"
  prefix_dash = "raskon-website-"
}
