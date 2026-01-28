resource "aws_ecs_service" "this" {
  name            = var.name
  cluster         = var.ecs_cluster_arn
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  platform_version = var.platform_version
  propagate_tags   = "SERVICE"

  enable_execute_command = var.enable_execute_command

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets = var.subnet_ids
    security_groups = (concat([aws_security_group.task.id], var.additional_security_group_ids))
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = merge(var.tags, {
    Service     = var.name
    ManagedBy   = "terraform"
  })

  depends_on = [aws_lb_listener_rule.this]
}
