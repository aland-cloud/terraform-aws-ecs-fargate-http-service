resource "aws_ecr_repository" "this" {
  count = var.create_ecr_repository ? 1 : 0

  name                 = coalesce(var.ecr_repository_name, var.name)
  image_tag_mutability = var.ecr_image_tag_mutability
  force_delete         = var.ecr_force_delete

  image_scanning_configuration {
    scan_on_push = var.ecr_scan_on_push
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(var.tags, {
    Service     = var.name
    ManagedBy   = "terraform"
  })
}

resource "aws_ecr_lifecycle_policy" "keep_last_n" {
  count      = var.create_ecr_repository ? 1 : 0
  repository = aws_ecr_repository.this[0].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last ${var.ecr_keep_last_images} tagged images; expire older ones"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = var.ecr_keep_last_images
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}