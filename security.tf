resource "aws_security_group" "task" {
  count       = var.create_task_security_group ? 1 : 0
  name        = "${var.name}-sg"
  description = "Task security group (inbound only from ALB)"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
    description     = "Allow ALB to reach service"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound"
  }

  tags = merge(var.tags, {
    Service     = var.name
    ManagedBy   = "terraform"
  })
}