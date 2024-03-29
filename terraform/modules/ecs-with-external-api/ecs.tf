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

variable "repository_name" {
  
}

variable "vpc_id" {
  
}

variable "region" {
  
}

variable "private_subnets" {
  
}

variable "public_subnets" {

}

variable "desired_task_count" {

}

variable "access_key_id" {
  
}

variable "secret_access_key" {
  
}



# ALB

resource "aws_alb" "alb" {
  name               = "${var.app_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = flatten(var.public_subnets)
  security_groups    = [aws_security_group.alb_sg.id]

  tags = {
    environment = var.environment
    managed_by  = var.managed_by
  }
}

resource "aws_alb_target_group" "tg" {
  name        = "${var.app_name}-${var.environment}-target-grp"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  tags = {
    environment = var.environment
    managed_by  = var.managed_by
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.alb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.tg.id
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
    environment = var.environment
    managed_by  = var.managed_by
  }
}

# ECS and ECR

resource "aws_ecr_repository" "ecr_repo" {
  name = var.repository_name
}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.app_name}-${var.environment}-ecs-cluster"
}

resource "aws_ecs_task_definition" "web_task" {
  family = "webworker"

  container_definitions = <<JSON
[
  {
    "name": "web_1",
    "image": "${aws_ecr_repository.ecr_repo.repository_url}",
    "portMappings": [
      {
        "hostPort": 3000,
        "protocol": "tcp",
        "containerPort": 3000
      }
    ],
    "memoryReservation": 300,
    "networkMode": "awsvpc",
    "environment": [
      {"name": "AWS_ACCESS_KEY_ID",  "value": "${var.access_key_id}"},
      {"name": "AWS_SECRET_ACCESS_KEY",  "value": "${var.secret_access_key}"}
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${var.app_name}-${var.environment}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "ecs-fargate"
      }
    }
  }
]
JSON

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  depends_on = [
    aws_cloudwatch_log_group.ecs_log_grp
  ]
}

resource "aws_security_group" "ecs_service" {
  vpc_id      = var.vpc_id
  name        = "${var.app_name}-${var.environment}-ecs-service-sg"
  description = "Allow egress from container"

  # Entering
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Exiting
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name        = "${var.app_name}-${var.environment}-ecs-service-sg"
    environment = var.environment
    managed_by = var.managed_by
  }
}

resource "aws_ecs_service" "web" {
  name            = "${var.app_name}-${var.environment}-web"
  task_definition = aws_ecs_task_definition.web_task.arn
  desired_count   = var.desired_task_count
  launch_type     = "FARGATE"
  cluster         = aws_ecs_cluster.cluster.id

  network_configuration {
    security_groups  = [aws_security_group.ecs_service.id]
    subnets          = flatten(var.private_subnets)
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.tg.id
    container_name   = "web_1"
    container_port   = "3000"
  }

  depends_on = [aws_alb_listener.http]
}

/* Role that the Amazon ECS container agent and the Docker daemon can assume */
resource "aws_iam_role" "ecs_execution_role" {
  name               = "ecs-task-execution-role"
  assume_role_policy = file("policies/ecs-assume-role-policy.json")
}

resource "aws_iam_role_policy" "ecs_execution_role_policy" {
  name   = "ecs-execution-role-policy"
  policy = file("policies/ecs-execution-role-policy.json")
  role   = aws_iam_role.ecs_execution_role.id
}

resource "aws_cloudwatch_log_group" "ecs_log_grp" {
  name = "/ecs/${var.app_name}-${var.environment}"

  tags = {
    name        = "${var.app_name}-${var.environment}-log-group"
    environment = var.environment
    managed_by   = var.managed_by
  }
}

output "ecr_repo_url" {
  value = aws_ecr_repository.ecr_repo.repository_url
}

output "ecs_service_name" {
  value = aws_ecs_service.web.name
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.cluster.name
}

output "load_balancer_address" {
  value = aws_alb.alb.dns_name
}
