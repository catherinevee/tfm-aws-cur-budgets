# Common computed values and configurations

locals {
  # Standard tags to be applied to all resources
  common_tags = merge(
    var.tags,
    {
      Module      = "finops"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )

  # S3 bucket configurations
  bucket_name = var.create_s3_bucket ? "${var.name_prefix}cur-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.id}" : null

  # IAM configurations
  role_name = var.create_iam_role ? "${var.name_prefix}budget-action-role" : null

  # Budget configurations
  budget_names = keys(var.budgets)
  action_names = keys(var.budget_actions)

  # Default KMS key policy
  kms_key_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CUR Service"
        Effect = "Allow"
        Principal = {
          Service = "cur.amazonaws.com"
        }
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ]
        Resource = "*"
      }
    ]
  })

  # S3 bucket policy for CUR
  s3_bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCURService"
        Effect = "Allow"
        Principal = {
          Service = "cur.amazonaws.com"
        }
        Action = [
          "s3:PutObject",
          "s3:GetBucketAcl",
          "s3:GetBucketPolicy"
        ]
        Resource = [
          var.create_s3_bucket ? "${aws_s3_bucket.cur_bucket[0].arn}" : var.existing_s3_bucket_arn,
          var.create_s3_bucket ? "${aws_s3_bucket.cur_bucket[0].arn}/*" : "${var.existing_s3_bucket_arn}/*"
        ]
      },
      {
        Sid    = "DenyUnencryptedUploads"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:PutObject"
        Resource = "${var.create_s3_bucket ? aws_s3_bucket.cur_bucket[0].arn : var.existing_s3_bucket_arn}/*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "aws:kms"
          }
        }
      },
      {
        Sid    = "DenyHTTP"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          var.create_s3_bucket ? "${aws_s3_bucket.cur_bucket[0].arn}" : var.existing_s3_bucket_arn,
          var.create_s3_bucket ? "${aws_s3_bucket.cur_bucket[0].arn}/*" : "${var.existing_s3_bucket_arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport": "false"
          }
        }
      }
    ]
  })
}
