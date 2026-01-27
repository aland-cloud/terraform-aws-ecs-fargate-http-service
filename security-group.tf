resource "aws_security_group" "task" {
  name        = "${var.name}-sg"
  description = "Task security group (inbound only from ALB)"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidr_blocks
    description = "Allow inbound to service from specified CIDR blocks"
  }

  dynamic "egress" {
    for_each = var.security_group_egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }

  tags = merge(var.tags, {
    Service     = var.name
    ManagedBy   = "terraform"
  })
}
