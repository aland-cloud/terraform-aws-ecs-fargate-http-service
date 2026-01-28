resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name}-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = tostring(var.cpu)
  memory                   = tostring(var.memory)

  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn

  container_definitions = var.custom_container_definitions != null ? var.custom_container_definitions : jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      essential = true

      portMappings = [{
        containerPort = var.container_port
        protocol      = "tcp"
      }]

      environment = [
        for k, v in var.environment_variables : {
          name  = k
          value = v
        }
      ]

      secrets = [
        for s in var.execution_role_secrets : {
          name      = s.name
          valueFrom = s.valueFrom
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = var.aws_region
          awslogs-group         = aws_cloudwatch_log_group.this[0].name
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = merge(var.tags, {
    Service     = var.name
    ManagedBy   = "terraform"
  })

}
