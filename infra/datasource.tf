data "aws_route53_zone" "public_zone" {
  name         = "avincm.live"
  private_zone = false
}
data "aws_ami" "web_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["avincm-test-*"]
  }
}
data "aws_route53_zone" "zone" {
  name         = "avincm.live"
  private_zone = false
}