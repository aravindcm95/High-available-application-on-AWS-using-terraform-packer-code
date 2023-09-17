variable "region" {
  description = "define aws region"
  default     = "ap-south-1"
  type        = string

}
variable "project" {
  description = "define project name"
  type        = string
  default     = "avincm"

}
variable "owner" {
  description = "define project name"
  type        = string
  default     = "aravindcm"

}
variable "env" {
  description = "define project enviornment"
  type        = string
  default     = "prod"

}
variable "vpc_cidr_block" {
  description = "Define cidr block of vpc "
  type        = string
  default     = "172.16.0.0/20"

}

variable "ami" {
  description = "Define ami id"
  type        = string

}
variable "instance_type" {
  description = "define instance type"
  type        = string

}
variable "certificate_arv" {
  default = "arn:aws:acm:ap-south-1:985010860775:certificate/53e1172d-65f9-4df6-9bac-3e1d14bbd534"
}
variable "ssl_policy" {
  default = "ELBSecurityPolicy-TLS13-1-2-2021-06"

}
variable "site_url" {
  default = "shop.avincm.live"
  
}