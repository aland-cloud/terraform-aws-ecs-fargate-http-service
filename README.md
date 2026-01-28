# terraform-aws-ecs-fargate-http-service

A reusable Terraform module for deploying **HTTP services on AWS ECS Fargate**
behind an **Application Load Balancer (ALB)**.

This module is designed for **public reuse**, follows **AWS best practices**,
and is suitable for **SOC2-aligned environments**.

---

## Features

- ECS Fargate service (private tasks, no public IP)
- Works with **existing public or internal ALB**
- ALB listener rule with **explicit priority**
- Target group with configurable health checks
- Dedicated task security group (ALB → task only)
- CloudWatch Logs with configurable retention
- ECS Service Auto Scaling (CPU + Memory)
- Optional CloudWatch alarms (CPU / Memory)
- IAM execution role + task role
- No hidden or automatic behavior

---

## Architecture

```
Internet / VPC
      |
      v
Application Load Balancer
      |
      v
Target Group
      |
      v
ECS Fargate Service (private subnets)
```

---

## Requirements

- Terraform >= 1.3
- AWS provider >= 5.x
- Existing AWS resources:
  - VPC
  - Subnets (private recommended)
  - ECS Cluster (Fargate)
  - ALB + Listener (HTTP or HTTPS)

---

## Example Usage

```hcl
module "example_service" {
  source = "/Users/davidghazazyan/avrioai/terraform-aws-ecs-fargate-http-service"

  name       = "example-service"
  aws_region = "us-west-2"

  # ECS / VPC
  ecs_cluster_arn  = "arn:aws:ecs:us-west-2:625966732367:cluster/staging-cluster"
  ecs_cluster_name = "staging-cluster"
  vpc_id           = "vpc-xxxxxxxx"
  subnet_ids       = ["subnet-aaaa", "subnet-bbbb"]

  # ALB integration
  alb_listener_arn      = "arn:aws:elasticloadbalancing:..."
  alb_security_group_id = "sg-xxxxxxxx"

  # Routing (explicit priority - REQUIRED)
  path_patterns          = ["/rest/*"]
  listener_rule_priority = 501

  # Container
  container_name    = "chat"
  container_image   = "xxxxxxxx.dkr.ecr.us-west-2.amazonaws.com/example-service:latest"
  container_port    = 8080
  health_check_path = "/rest/rest/test/hello.json"

  # Task resources
  cpu    = 512
  memory = 1024

  # Service
  desired_count          = 1
  assign_public_ip       = false
  enable_execute_command = false

  # Production settings
  platform_version                   = "1.4.0"
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  target_group_deregistration_delay  = 30

  # Autoscaling
  enable_autoscaling         = true
  autoscaling_min_capacity  = 1
  autoscaling_max_capacity  = 2
  autoscaling_cpu_target    = 60
  autoscaling_memory_target = 75

  # CloudWatch alarms
  enable_cloudwatch_alarms = true
  cpu_high_threshold       = 80
  memory_high_threshold    = 85

  tags = {
    Environment = "staging"
    Project     = "example"
    ManagedBy   = "terraform"
  }
}
```

---

## Listener Rule Priority

This module requires an **explicit ALB listener rule priority**.

```hcl
listener_rule_priority = 501
```

### Important notes

- ALB listener rule priorities **must be unique**
- If two services use the same priority, Terraform will fail with:
  `PriorityInUse`
- The module **does not auto-generate priorities**
- This is intentional and avoids hidden or unpredictable behavior

This approach is:
- Deterministic
- Safe for production
- SOC2 / audit friendly

---

## Autoscaling

The module uses **Application Auto Scaling** for ECS services.

Supported metrics:
- CPU utilization
- Memory utilization

Autoscaling manages the ECS service `desired_count`.

---

## CloudWatch Alarms

Optional alarms:
- `<service>-cpu-high`
- `<service>-memory-high`

Alarms can optionally notify an SNS topic.

```hcl
alarm_sns_topic_arn = "arn:aws:sns:us-west-2:ACCOUNT:alerts"
```

If `null`, alarms are created without notifications.

---

## Secrets (SSM Parameter Store / Secrets Manager)

This module supports injecting sensitive values into containers using **AWS Systems Manager Parameter Store** (recommended for simple key/value secrets) or **AWS Secrets Manager**.

Secrets are injected into the container as environment variables via the ECS **execution role**. Secret values are **not stored in Terraform state**.

### Example: 3 secrets from SSM Parameter Store

```hcl
module "example_service" {
  # ... other required variables ...

  secrets = [
    {
      name      = "DB_PASSWORD"
      valueFrom = "arn:aws:ssm:us-west-2:123456789012:parameter/example/db-password"
    },
    {
      name      = "JWT_SECRET"
      valueFrom = "arn:aws:ssm:us-west-2:123456789012:parameter/example/jwt-secret"
    },
    {
      name      = "API_KEY"
      valueFrom = "arn:aws:ssm:us-west-2:123456789012:parameter/example/api-key"
    }
  ]
}
```

### Notes

- Create SSM parameters as **SecureString** (or use Secrets Manager).
- Do **not** put secret values in `environment_variables`.
- Updating a secret usually requires a **new deployment** (restart tasks) to pick up the new value.
- The module grants read access only to the ARNs you pass in `secrets` (least privilege).

---

## Configuration Options

### Security Configuration

**Security Group Egress Rules**
```hcl
security_group_egress_rules = [
  {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS outbound"
  },
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP outbound"
  }
]
```

**ECS Exec** (disabled by default for security)
```hcl
enable_execute_command = false  # Default: false
```

### Production Settings

**Platform Version** (pinned for stability)
```hcl
platform_version = "1.4.0"  # Default: 1.4.0 (not LATEST)
```

**Deployment Configuration**
```hcl
deployment_minimum_healthy_percent = 50   # Default: 100
deployment_maximum_percent         = 150  # Default: 200
```

**Target Group Settings**
```hcl
target_group_deregistration_delay = 60  # Default: 30 seconds
```

### Resource Limits

**Task-level resources** (Fargate manages at task level)
```hcl
cpu    = 1024  # Must be: 256, 512, 1024, 2048, 4096
memory = 2048  # Must match valid CPU/Memory combinations
```

---

## Security Best Practices

- ECS tasks run in private subnets
- No public IPs assigned to tasks by default
- Inbound traffic allowed only from ALB security group
- IAM roles follow least-privilege principle
- Deployment circuit breaker enabled
- ECS Exec disabled by default for security
- Platform version pinned (not LATEST) for stability
- Configurable egress rules with secure defaults
- Explicit, predictable infrastructure behavior


## SOC2 Notes

This module supports SOC2-aligned controls:

- Network isolation
- Monitoring and alerting
- Deterministic configuration
- No implicit or hidden automation
- Clear responsibility boundaries

---

## Outputs

- ECS service name
- Task definition ARN
- Target group ARN
- CloudWatch log group name

---

## License

This project is licensed under the **MIT License**.

Copyright (c) 2026 **Alandcloud**

See the [LICENSE](LICENSE) file for details.
