provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project = var.project
      owner   = var.owner
    }
  }
}
############## backend server configuration ##################
terraform {
  backend "s3" {
    bucket = "terraform-avincm.live"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}
