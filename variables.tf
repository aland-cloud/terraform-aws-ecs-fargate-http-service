###############################################################################
# variables.tf (Terraform v1.5.x compatible)
# - NO variable "validation" blocks that reference other variables
# - ALL validations are implemented as `check` blocks with `assert { ... }`
###############################################################################

############################
# Global Variables
############################
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

############################
# ECS Service Variables
############################
variable "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  type        = string
}

variable "desired_count" {
  description = "Desired task count"
  type        = number
  default     = 1
}

variable "platform_version" {
  description = "ECS platform version for Fargate"
  type        = string
  default     = "1.4.0"
}

variable "enable_execute_command" {
  description = "Enable ECS Exec"
  type        = bool
  default     = false
}

variable "deployment_minimum_healthy_percent" {
  description = "Lower limit on the number of running tasks during deployments"
  type        = number
  default     = 100
}

variable "deployment_maximum_percent" {
  description = "Upper limit on the number of running tasks during deployments"
  type        = number
  default     = 200
}

variable "health_check_grace_period_seconds" {
  description = "Time in seconds to ignore ALB target health check failures after a new task starts. Use this to give the application startup time before ECS considers the task unhealthy."
  type        = number
  default     = 0
}

############################
# Networking Variables
############################
variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet ids for Fargate tasks"
  type        = list(string)
}

variable "assign_public_ip" {
  type    = bool
  default = false
}

############################
# Task Definition Variables
############################
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

variable "custom_container_definitions" {
  description = "Custom container definitions JSON. If provided, this will be used instead of the generic container configuration. Must be valid JSON string."
  type        = string
  default     = null
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

variable "environment_variables" {
  description = "Plain env vars"
  type        = map(string)
  default     = {}
}

variable "execution_role_secrets" {
  description = "Secrets Manager/SSM parameters to inject"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

############################
# ALB Variables
############################
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
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/health"
}

variable "host_headers" {
  description = "Optional host headers for listener rule (e.g. [\"api.example.com\"]). Set null to disable host header condition."
  type        = list(string)
  default     = null
}

variable "target_group_deregistration_delay" {
  description = "Time for ELB to wait before changing deregistering target from draining to unused"
  type        = number
  default     = 30
}

############################
# Security Group Variables
############################
variable "alb_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to reach the service on container_port (e.g. ALB subnet CIDRs, corporate NAT, etc.)"
  type        = list(string)
  default     = []
}

variable "additional_security_group_ids" {
  description = "Additional security group IDs to attach to the task ENI (appended to the managed task security group)"
  type        = list(string)
  default     = []
}

variable "security_group_egress_rules" {
  description = "List of egress rules for the task security group. If not provided, defaults to allow all outbound traffic."
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string))
    description = string
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow outbound"
    }
  ]
}

############################
# IAM Variables
############################
variable "task_role_inline_policy_json" {
  description = "Optional inline policy JSON to attach to the task role"
  type        = string
  default     = null
}

############################
# ECR Variables
############################
variable "create_ecr_repository" {
  description = "Whether to create ECR repository"
  type        = bool
  default     = true
}

# (Kept as-is from your original, though it duplicates create_ecr_repository)
variable "ecr_repo" {
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

variable "ecr_keep_last_images" {
  description = "Number of most recent images to keep in the ECR repository (older images will be expired by lifecycle policy)."
  type        = number
  default     = 20
}

############################
# CloudWatch Logs Variables
############################
variable "enable_cloudwatch_logs" {
  description = "Enable cloudwatch logs: true|false"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention"
  type        = number
  default     = 30
}

variable "cloudwatch_log_kms_key_id" {
  description = "Optional KMS key ID/ARN to encrypt the CloudWatch Log Group. If null, AWS-managed encryption is used."
  type        = string
  default     = null
}

############################
# CloudWatch Alarms Variables
############################
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

############################
# Autoscaling Variables
############################
variable "enable_autoscaling" {
  type        = bool
  description = "Enable ECS Service autoscaling"
  default     = true
}

variable "enable_cpu_scaling" {
  type        = bool
  description = "Enable CPU-based autoscaling (requires enable_autoscaling = true)"
  default     = true
}

variable "enable_memory_scaling" {
  type        = bool
  description = "Enable memory-based autoscaling (requires enable_autoscaling = true)"
  default     = false
}

variable "enable_alb_request_scaling" {
  type        = bool
  description = "Enable ALB request count per target autoscaling (requires enable_autoscaling = true)"
  default     = false
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

variable "autoscaling_alb_request_target" {
  type        = number
  description = "Target ALB requests per target for autoscaling"
  default     = 1000
}

###############################################################################
# CHECKS (Terraform v1.5.x syntax)
###############################################################################

check "deployment_minimum_healthy_percent_range" {
  assert {
    condition     = var.deployment_minimum_healthy_percent >= 0 && var.deployment_minimum_healthy_percent <= 100
    error_message = "deployment_minimum_healthy_percent must be between 0 and 100."
  }
}

check "deployment_maximum_percent_range" {
  assert {
    condition     = var.deployment_maximum_percent >= 100 && var.deployment_maximum_percent <= 200
    error_message = "deployment_maximum_percent must be between 100 and 200."
  }
}

check "target_group_deregistration_delay_range" {
  assert {
    condition     = var.target_group_deregistration_delay >= 0 && var.target_group_deregistration_delay <= 3600
    error_message = "target_group_deregistration_delay must be between 0 and 3600 seconds."
  }
}

check "alb_ingress_cidr_blocks_nonempty" {
  assert {
    condition     = length(var.alb_ingress_cidr_blocks) > 0
    error_message = "alb_ingress_cidr_blocks must contain at least one CIDR block."
  }
}

check "listener_rule_priority_positive" {
  assert {
    condition     = var.listener_rule_priority > 0
    error_message = "listener_rule_priority must be > 0."
  }
}

check "container_port_range" {
  assert {
    condition     = var.container_port >= 1 && var.container_port <= 65535
    error_message = "container_port must be between 1 and 65535."
  }
}

check "cpu_allowed_values" {
  assert {
    condition     = contains([256, 512, 1024, 2048, 4096], var.cpu)
    error_message = "cpu must be one of: 256, 512, 1024, 2048, 4096."
  }
}

check "fargate_cpu_memory_combo" {
  assert {
    condition = (
    (var.cpu == 256  && contains([512, 1024, 2048], var.memory)) ||
    (var.cpu == 512  && contains([1024, 2048, 3072, 4096], var.memory)) ||
    (var.cpu == 1024 && contains([2048, 3072, 4096, 5120, 6144, 7168, 8192], var.memory)) ||
    (var.cpu == 2048 && var.memory >= 4096 && var.memory <= 16384 && var.memory % 1024 == 0) ||
    (var.cpu == 4096 && var.memory >= 8192 && var.memory <= 30720 && var.memory % 1024 == 0)
    )
    error_message = "Invalid CPU/Memory combination. See AWS Fargate documentation for valid combinations."
  }
}

check "custom_container_definitions_is_valid_json_if_set" {
  assert {
    condition     = var.custom_container_definitions == null || can(jsondecode(var.custom_container_definitions))
    error_message = "custom_container_definitions must be a valid JSON string when provided."
  }
}

check "ecr_image_tag_mutability_enum" {
  assert {
    condition     = contains(["IMMUTABLE", "MUTABLE"], var.ecr_image_tag_mutability)
    error_message = "ecr_image_tag_mutability must be IMMUTABLE or MUTABLE."
  }
}

check "ecr_keep_last_images_range" {
  assert {
    condition     = var.ecr_keep_last_images >= 1 && var.ecr_keep_last_images <= 1000
    error_message = "ecr_keep_last_images must be between 1 and 1000."
  }
}

check "autoscaling_requires_a_policy" {
  assert {
    condition = (
    !var.enable_autoscaling ||
    var.enable_cpu_scaling ||
    var.enable_memory_scaling ||
    var.enable_alb_request_scaling
    )
    error_message = "When enable_autoscaling is true, at least one of enable_cpu_scaling, enable_memory_scaling, or enable_alb_request_scaling must be true."
  }
}

check "autoscaling_capacity_bounds" {
  assert {
    condition     = var.autoscaling_min_capacity >= 0 && var.autoscaling_max_capacity >= var.autoscaling_min_capacity
    error_message = "autoscaling_min_capacity must be >= 0 and autoscaling_max_capacity must be >= autoscaling_min_capacity."
  }
}

check "autoscaling_cpu_target_range" {
  assert {
    condition     = var.autoscaling_cpu_target > 0 && var.autoscaling_cpu_target <= 100
    error_message = "autoscaling_cpu_target must be between 1 and 100."
  }
}

check "autoscaling_alb_request_target_positive" {
  assert {
    condition     = var.autoscaling_alb_request_target > 0
    error_message = "autoscaling_alb_request_target must be > 0."
  }
}

check "cloudwatch_retention_days_positive" {
  assert {
    condition     = var.log_retention_days > 0
    error_message = "log_retention_days must be > 0."
  }
}

check "alarm_period_seconds_positive" {
  assert {
    condition     = var.alarm_period_seconds > 0
    error_message = "alarm_period_seconds must be > 0."
  }
}

check "alarm_evaluation_periods_positive" {
  assert {
    condition     = var.alarm_evaluation_periods > 0
    error_message = "alarm_evaluation_periods must be > 0."
  }
}

check "thresholds_sane" {
  assert {
    condition = (
    var.cpu_high_threshold > 0 && var.cpu_high_threshold <= 100 &&
    var.memory_high_threshold > 0 && var.memory_high_threshold <= 100
    )
    error_message = "cpu_high_threshold and memory_high_threshold must be between 1 and 100."
  }
}

check "subnet_ids_reasonable_for_ha" {
  assert {
    condition     = length(var.subnet_ids) >= 2
    error_message = "subnet_ids should contain at least 2 subnets for high availability."
  }
}