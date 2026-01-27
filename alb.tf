resource "aws_lb_target_group" "this" {
  name                 = "${var.name}-tg"
  port                 = var.container_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = var.target_group_deregistration_delay

  health_check {
    enabled             = true
    path                = var.health_check_path
    protocol            = "HTTP"
    matcher             = "200-399"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
  }

  tags = merge(var.tags, {
    Service     = var.name
    ManagedBy   = "terraform"
  })
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = var.alb_listener_arn
  priority     = var.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  dynamic "condition" {
    for_each = var.host_headers == null ? [] : [1]
    content {
      host_header {
        values = var.host_headers
      }
    }
  }

  condition {
    path_pattern {
      values = var.path_patterns
    }
  }

  tags = merge(var.tags, {
    Service     = var.name
    ManagedBy   = "terraform"
  })
}
