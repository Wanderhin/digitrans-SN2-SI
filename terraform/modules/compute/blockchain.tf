# ECS Task Definition and Service for Blockchain Node

resource "aws_ecs_task_definition" "blockchain" {
  family                   = "${var.project_name}-${var.environment}-blockchain"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "blockchain-service"
      image     = "${aws_ecr_repository.services["blockchain-service"].repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 8545
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "ENVIRONMENT"
          value = var.environment
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs["blockchain"].name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "wget -qO- http://localhost:8545/ || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = {
    Name    = "${var.project_name}-${var.environment}-blockchain-task"
    Service = "Blockchain"
  }
}

resource "aws_ecs_service" "blockchain" {
  name            = "${var.project_name}-${var.environment}-blockchain"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.blockchain.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_app_subnet_ids
    security_groups  = [var.ecs_tasks_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.services["blockchain"].arn
    container_name   = "blockchain-service"
    container_port   = 8545
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
    Name    = "${var.project_name}-${var.environment}-blockchain-service"
    Service = "Blockchain"
  }

  depends_on = [aws_lb_listener.https]
}
