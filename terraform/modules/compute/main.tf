# Module Compute - ECS Fargate avec Auto Scaling

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-cluster"
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "ecs" {
  for_each = toset(["erp", "crm", "supply-chain", "bi", "blockchain"])

  name              = "/aws/ecs/${var.project_name}/${var.environment}/${each.key}"
  retention_in_days = 30
  kms_key_id        = var.kms_key_arn

  tags = {
    Name    = "${var.project_name}-${var.environment}-${each.key}-logs"
    Service = each.key
  }
}

# ECR Repositories
resource "aws_ecr_repository" "services" {
  for_each = toset(["erp-service", "crm-service", "supply-chain-service", "bi-service", "blockchain-service"])

  name                 = "${var.project_name}/${each.key}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn
  }

  tags = {
    Name = "${var.project_name}-${each.key}"
  }
}

# ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "services" {
  for_each   = aws_ecr_repository.services
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images after 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = true
  enable_http2               = true
  enable_cross_zone_load_balancing = true

  drop_invalid_header_fields = true

  access_logs {
    bucket  = var.alb_logs_bucket
    enabled = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-alb"
  }
}

# Target Groups pour chaque service
resource "aws_lb_target_group" "services" {
  for_each = {
    erp          = 8081
    crm          = 8082
    supply-chain = 8083
    bi           = 8084
    blockchain   = 8545
  }

  name        = "${var.project_name}-${var.environment}-${each.key}-tg"
  port        = each.value
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = each.key == "blockchain" ? "/" : "/actuator/health"
    matcher             = "200"
  }

  deregistration_delay = 30

  tags = {
    Name    = "${var.project_name}-${var.environment}-${each.key}-tg"
    Service = each.key
  }
}

# ALB Listener HTTPS
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Service not found"
      status_code  = "404"
    }
  }
}

# ALB Listener HTTP (redirect to HTTPS)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
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

# ALB Listener Rules
resource "aws_lb_listener_rule" "erp" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services["erp"].arn
  }

  condition {
    path_pattern {
      values = ["/api/employees*", "/api/suppliers*", "/api/auth/login"]
    }
  }
}

resource "aws_lb_listener_rule" "crm" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services["crm"].arn
  }

  condition {
    path_pattern {
      values = ["/api/customers*", "/api/orders*"]
    }
  }
}

resource "aws_lb_listener_rule" "supply_chain" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 300

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services["supply-chain"].arn
  }

  condition {
    path_pattern {
      values = ["/api/products*", "/api/shipments*"]
    }
  }
}

resource "aws_lb_listener_rule" "bi" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 400

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services["bi"].arn
  }

  condition {
    path_pattern {
      values = ["/api/dashboard*"]
    }
  }
}

resource "aws_lb_listener_rule" "blockchain" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 500

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services["blockchain"].arn
  }

  condition {
    path_pattern {
      values = ["/rpc"]
    }
  }
}

# ECS Task Definitions
resource "aws_ecs_task_definition" "erp" {
  family                   = "${var.project_name}-${var.environment}-erp"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "erp-service"
      image     = "${aws_ecr_repository.services["erp-service"].repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 8081
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "SPRING_PROFILES_ACTIVE"
          value = var.environment
        },
        {
          name  = "SERVER_PORT"
          value = "8081"
        }
      ]



      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs["erp"].name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8081/actuator/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = {
    Name    = "${var.project_name}-${var.environment}-erp-task"
    Service = "ERP"
  }
}

# ECS Services
resource "aws_ecs_service" "erp" {
  name            = "${var.project_name}-${var.environment}-erp"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.erp.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_app_subnet_ids
    security_groups  = [var.ecs_tasks_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.services["erp"].arn
    container_name   = "erp-service"
    container_port   = 8081
  }

  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 100
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  enable_execute_command = true

  tags = {
    Name    = "${var.project_name}-${var.environment}-erp-service"
    Service = "ERP"
  }

  depends_on = [aws_lb_listener.https]
}

# Auto Scaling pour ECS Service
resource "aws_appautoscaling_target" "erp" {
  max_capacity       = 10
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.erp.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "erp_cpu" {
  name               = "${var.project_name}-${var.environment}-erp-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.erp.resource_id
  scalable_dimension = aws_appautoscaling_target.erp.scalable_dimension
  service_namespace  = aws_appautoscaling_target.erp.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# Outputs
output "ecs_cluster_id" {
  value = aws_ecs_cluster.main.id
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "ecr_repository_urls" {
  value = {
    for k, v in aws_ecr_repository.services : k => v.repository_url
  }
}

# Variables
variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_app_subnet_ids" {
  type = list(string)
}

variable "alb_security_group_id" {
  type = string
}

variable "ecs_tasks_security_group_id" {
  type = string
}

variable "ecs_task_execution_role_arn" {
  type = string
}

variable "ecs_task_role_arn" {
  type = string
}

variable "kms_key_arn" {
  type = string
}



variable "alb_logs_bucket" {
  type = string
}

variable "acm_certificate_arn" {
  type = string
}
