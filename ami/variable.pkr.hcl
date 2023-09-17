variable "project" {
  description = "define project name"
  type        = string
  default     = "avincm"
}
variable "region" {
  description = "define aws region"
  type        = string
  default     = "ap-south-1"
}
variable "env" {
  description = "define project enviornment"
  type        = string
  default     = "test"
}
variable "ami" {
  description = "define ami id"
  type        = string
  default     = "ami-05552d2dcf89c9b24"
}
locals {
  image-timestamp = "${formatdate("DD-MM-YYYY-hh-mm", timestamp())}"
  image-name      = "${var.project}-${var.env}-${local.image-timestamp}"
}