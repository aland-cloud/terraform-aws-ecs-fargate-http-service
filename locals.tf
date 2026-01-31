data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

locals {
  ecs_cluster_name = split("/", var.ecs_cluster_arn)[length(split("/", var.ecs_cluster_arn)) - 1]

  alarm_actions = (var.alarm_sns_topic_arn != null) ? [var.alarm_sns_topic_arn] : []

  exec_secret_arns = distinct([
    for s in var.execution_role_secrets :
    "${replace(s.valueFrom, "/:[^:]*::?$/", "")}*"
    if can(regex("^arn:aws:secretsmanager:", s.valueFrom))
  ])

  exec_ssm_param_arns = distinct([
    for s in var.execution_role_secrets : (
      can(regex("^arn:aws:ssm:", s.valueFrom))
      ? s.valueFrom
      : "arn:${data.aws_partition.current.partition}:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter${s.valueFrom}"
    )
    if !can(regex("^arn:aws:secretsmanager:", s.valueFrom))
  ])
}