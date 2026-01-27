variable "name" {
  description = "Service name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

# ECS
variable "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  type        = string
}

# Networking
variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet ids for Fargate tasks"
  type        = list(string)
}

variable "assign_public_ip" {
  description = "SOC2 default: false (keep tasks private)"
  type        = bool
  default     = false
}

# Container / Task
variable "container_image" {
  description = "Container image"
  type        = string
}

variable "container_name" {
  description = "Container name"
  type        = string
  default     = "app"
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "Fargate CPU units"
  type        = number
  default     = 512
}

variable "memory" {
  description = "Fargate memory MiB"
  type        = number
  default     = 1024
}

variable "desired_count" {
  description = "Desired task count"
  type        = number
  default     = 1
}

# ALB integration
variable "alb_listener_arn" {
  description = "ALB listener ARN (HTTPS for public ALB; HTTP for internal ALB currently)"
  type        = string
}

variable "path_patterns" {
  description = "Path patterns for listener rule"
  type        = list(string)
  default     = ["/*"]
}

variable "listener_rule_priority" {
  description = "Listener rule priority (must be unique per listener)"
  type        = number
  default     = 100
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/health"
}

# Env / Secrets
variable "environment_variables" {
  description = "Plain env vars (avoid secrets/PHI here)"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secrets Manager/SSM parameters to inject"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

# Logging (SOC2 evidence)
variable "log_retention_days" {
  description = "CloudWatch log retention"
  type        = number
  default     = 30
}

variable "enable_execute_command" {
  description = "Enable ECS Exec"
  type        = bool
  default     = true
}

variable "create_ecr_repository" {
  description = "Whether to create ECR repository"
  type        = bool
  default     = true
}

variable "ecr_repository_name" {
  description = "ECR repository name (default: service name)"
  type        = string
  default     = null
}

variable "ecr_image_tag_mutability" {
  description = "Image tag mutability"
  type        = string
  default     = "IMMUTABLE"
  validation {
    condition     = contains(["IMMUTABLE", "MUTABLE"], var.ecr_image_tag_mutability)
    error_message = "Must be IMMUTABLE or MUTABLE"
  }
}

variable "ecr_scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "ecr_force_delete" {
  description = "Allow force delete of ECR repo"
  type        = bool
  default     = false
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB that is allowed to reach the service (used when create_task_security_group = true)"
  type        = string
}

variable "create_task_security_group" {
  description = "Create a dedicated task security group that only allows inbound from the ALB security group"
  type        = bool
  default     = true
}

variable "additional_security_group_ids" {
  description = "Additional security group IDs to attach to the task ENI (appended to the managed task security group)"
  type        = list(string)
  default     = []

  validation {
    condition     = var.create_task_security_group ? true : length(var.additional_security_group_ids) > 0
    error_message = "When create_task_security_group is false, you must provide at least one security group in additional_security_group_ids."
  }
}

variable "host_headers" {
  description = "Optional host headers for listener rule (e.g. [\"api.example.com\"]). Set null to disable host header condition."
  type        = list(string)
  default     = null
}

variable "cloudwatch_log_kms_key_id" {
  description = "Optional KMS key ID/ARN to encrypt the CloudWatch Log Group. If null, AWS-managed encryption is used."
  type        = string
  default     = null
}

variable "enable_autoscaling" {
  type        = bool
  description = "Enable ECS Service autoscaling"
  default     = true
}

variable "autoscaling_min_capacity" {
  type        = number
  description = "Minimum desired count when autoscaling is enabled"
  default     = 1
}

variable "autoscaling_max_capacity" {
  type        = number
  description = "Maximum desired count when autoscaling is enabled"
  default     = 4
}

variable "autoscaling_cpu_target" {
  type        = number
  description = "Target CPU utilization percentage"
  default     = 60
}

variable "autoscaling_memory_target" {
  type        = number
  description = "Target Memory utilization percentage (set null to disable memory-based scaling)"
  default     = null
}

variable "ecs_cluster_name" {
  description = "ECS cluster name (needed for autoscaling resource_id)"
  type        = string
}

variable "enable_cloudwatch_alarms" {
  description = "Enable CloudWatch alarms for ECS service"
  type        = bool
  default     = true
}

variable "alarm_sns_topic_arn" {
  description = "SNS topic ARN for alarm notifications (optional)"
  type        = string
  default     = null
}

variable "alarm_actions_enabled" {
  description = "Whether alarm actions are enabled"
  type        = bool
  default     = true
}

variable "alarm_evaluation_periods" {
  description = "Number of evaluation periods"
  type        = number
  default     = 2
}

variable "alarm_period_seconds" {
  description = "Alarm period in seconds"
  type        = number
  default     = 60
}

variable "cpu_high_threshold" {
  description = "CPU utilization percentage threshold"
  type        = number
  default     = 80
}

variable "memory_high_threshold" {
  description = "Memory utilization percentage threshold"
  type        = number
  default     = 85
}