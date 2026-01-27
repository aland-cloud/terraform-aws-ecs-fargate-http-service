locals {
  alarm_actions = (
  var.alarm_sns_topic_arn != null && var.alarm_sns_topic_arn != ""
  ) ? [var.alarm_sns_topic_arn] : []
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  count               = var.enable_cloudwatch_alarms ? 1 : 0
  alarm_name          = "${var.name}-cpu-high"
  alarm_description   = "ECS service CPU utilization is high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  period              = var.alarm_period_seconds
  statistic           = "Average"
  threshold           = var.cpu_high_threshold
  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = aws_ecs_service.this.name
  }

  actions_enabled = var.alarm_actions_enabled
  alarm_actions   = local.alarm_actions
  ok_actions      = local.alarm_actions

  tags = merge(var.tags, {
    ManagedBy = "terraform"
    Service   = var.name
  })
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  count               = var.enable_cloudwatch_alarms ? 1 : 0
  alarm_name          = "${var.name}-memory-high"
  alarm_description   = "ECS service Memory utilization is high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  period              = var.alarm_period_seconds
  statistic           = "Average"
  threshold           = var.memory_high_threshold
  namespace           = "AWS/ECS"
  metric_name         = "MemoryUtilization"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = aws_ecs_service.this.name
  }

  actions_enabled = var.alarm_actions_enabled
  alarm_actions   = local.alarm_actions
  ok_actions      = local.alarm_actions

  tags = merge(var.tags, {
    ManagedBy = "terraform"
    Service   = var.name
  })
}