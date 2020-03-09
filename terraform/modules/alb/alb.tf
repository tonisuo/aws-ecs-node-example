variable "vpc_cidr" {
  
}

variable "environment" {
  
}

variable "managed_by" {
  
}

variable "app_name" {
  
}

variable "az_count" {
  
}

variable "vpc_id" {
  
}

variable "vpc_public_subnet_id" {
  
}




resource "aws_alb" "alb" {
  name               = "${var.app_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.vpc_public_subnet_id
  security_groups    = ["${aws_security_group.alb_sg.id}"]

  tags {
    environment = "${var.environment}"
    managed_by  = "${var.managed_by}"
  }
}

resource "aws_alb_target_group" "tg" {
  name        = "${var.app_name}-${var.environment}-target-grp"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  tags = {
    environment = "${var.environment}"
    managed_by  = "${var.managed_by}"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = "${aws_alb.alb.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.tg.id}"
    type             = "forward"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.app_name}-${var.environment}-alb-sg"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name        = "${var.app_name}-${var.environment}-alb-sg"
    environment = "${var.environment}"
    managed_by  = "${var.managed_by}"
  }
}

output "load_balancer_address" {
  value = aws_alb.alb.dns_name
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "alb_target_group_id" {
  value = aws_alb_target_group.tg.id
}


