############ VPC module ############
module "vpc" {
  source     = ".\\modules\\vpc"
  project    = var.project
  env        = var.env
  cidr_block = var.vpc_cidr_block
}
################# bastion security_group ##################
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Allow ssh inbound traffic"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description = "allow ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project}_${var.env}_bastion_sg"
  }
}
################# web server security_group ###############
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow ssh/http inbound traffic"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description     = "allow ssh"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]

  }
  ingress {
    description      = "allow http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project}_${var.env}_web_sg"
  }
}
################# backend security_group ##################
resource "aws_security_group" "backend_sg" {
  name        = "backend_sg"
  description = "Allow 3306 inbound traffic"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description     = "allow ssh"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]

  }
  ingress {
    description     = "allow 3306"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project}_${var.env}_backend_sg"
  }
}
################# ALB security_group ######################
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow http/https inbound traffic"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description     = "allow http"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]

  }
  ingress {
    description      = "allow https"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project}_${var.env}_alb_sg"
  }
}
################# ssh_key_pair ############################
resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.project}_${var.env}_ssh_key"
  public_key = file(".mykey.pub")
  tags = {
    Name = "${var.project}_${var.project}_ssh_key"
  }
}
################# bastion server creation ##################
resource "aws_instance" "bastion_srv" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ssh_key.id
  subnet_id              = module.vpc.public_subnet1_id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  user_data              = file(".bastion_userdata.sh")
  tags = {
    Name = "${var.project}_${var.env}_bastion_srv"
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_security_group.bastion_sg]

}
################# eip for bastion server  ##################
resource "aws_eip" "bastion_eip" {
  domain = "vpc"
  tags = {
    Name = "${var.project}_${var.env}_bastion_eip"
  }
}
################# bastion server eip assocation #############
resource "aws_eip_association" "bastion_eip_assoc" {
  instance_id   = aws_instance.bastion_srv.id
  allocation_id = aws_eip.bastion_eip.id
  depends_on    = [aws_instance.bastion_srv, aws_eip.bastion_eip]
}
################# backned server creation ##################
resource "aws_instance" "backend_srv" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ssh_key.id
  subnet_id              = module.vpc.private_subnet4_id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  user_data              = file(".\bastion_userdata.sh")
  tags = {
    Name = "${var.project}_${var.env}_backend_srv"
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_security_group.backend_sg]

}
################# websrv1 server creation ##################
resource "aws_instance" "websrv1" {
  ami                    = data.aws_ami.web_ami.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ssh_key.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  subnet_id              = module.vpc.public_subnet2_id
  tags = {
    Name = "${var.project}_${var.env}_web_srv-1"
  }

}
################# websrv2 server creation ##################
resource "aws_instance" "websrv2" {
  ami                    = data.aws_ami.web_ami.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ssh_key.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  subnet_id              = module.vpc.public_subnet1_id
  tags = {
    Name = "${var.project}_${var.env}_web_srv-1"
  }

}



########## Target group creation #############

resource "aws_lb_target_group" "target_group" {
  name     = "${var.project}-webtg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  health_check {
    protocol            = "HTTP"
    path                = "/"
    healthy_threshold   = "3"
    unhealthy_threshold = "2"
    timeout             = "2"
    interval            = "5"
  }
  depends_on = [aws_instance.websrv1, aws_instance.websrv2]
}

############# target group attachement ###################

resource "aws_lb_target_group_attachment" "web1_atg" {

  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.websrv1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web2_atg" {

  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.websrv2.id
  port             = 80
}
############### application load balancer creation ################
resource "aws_lb" "alb" {
  name                       = "${var.project}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = [module.vpc.public_subnet1_id, module.vpc.public_subnet2_id, module.vpc.public_subnet3_id]
  enable_deletion_protection = false

}

############### alb 443 listener creation####################
resource "aws_lb_listener" "listener443" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arv

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}
################ alb redirection rule for HTTP request ##############
resource "aws_lb_listener" "listener80" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

################## adding  route53 record #####################
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.zone.id
  name    = var.site_url
  type    = "A"



  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}