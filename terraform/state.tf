// This block tells Terraform that we're going to provision AWS resources.
provider "aws" {
  region = "us-east-1"
}

// This block tells Terraform to save the state file in the specified bucket
terraform {
  backend "s3" {
    bucket  = "raskon-terraform"
    key     = "us-east-1/prd/raskon-website.tfstate"
    region  = "us-east-1"
    encrypt = "true"
  }
}
