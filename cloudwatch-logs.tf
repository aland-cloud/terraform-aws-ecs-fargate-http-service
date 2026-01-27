resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.cloudwatch_log_kms_key_id

  tags = merge(var.tags, {
    Service     = var.name
    ManagedBy   = "terraform"
  })
}