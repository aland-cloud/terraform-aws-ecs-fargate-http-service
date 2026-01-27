output "service_name" {
  value = aws_ecs_service.this.name
}

output "service_arn" {
  value = aws_ecs_service.this.arn
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.this.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.this.arn
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.this.name
}

output "listener_rule_arn" {
  value = aws_lb_listener_rule.this.arn
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = var.create_ecr_repository ? aws_ecr_repository.this[0].repository_url : null
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = var.create_ecr_repository ? aws_ecr_repository.this[0].arn : null
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = var.create_ecr_repository ? aws_ecr_repository.this[0].name : null
}

output "task_security_group_id" {
  description = "Managed task security group ID (null if create_task_security_group=false)"
  value       = var.create_task_security_group ? aws_security_group.task[0].id : null
}