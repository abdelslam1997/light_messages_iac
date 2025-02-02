############################################
# Random String for S3 Bucket Name
############################################
resource "random_string" "bucket_suffix" {
  length  = 4
  special = false
  upper   = false
}

############################################
# S3 Bucket for Django Media Storage
############################################
resource "aws_s3_bucket" "django_storage" {
  bucket = "${var.environment}-django-storage-${random_string.bucket_suffix.result}"

  tags = local.common_tags
}

# Disable versioning for the bucket
resource "aws_s3_bucket_versioning" "django_storage" {
  bucket = aws_s3_bucket.django_storage.id

  versioning_configuration {
    status = "Disabled"
  }
}

# Block public access to the bucket
resource "aws_s3_bucket_public_access_block" "django_storage" {
  bucket = aws_s3_bucket.django_storage.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Add bucket policy to allow public read access
resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket = aws_s3_bucket.django_storage.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.django_storage.arn}/*"
      },
    ]
  })

  depends_on = [
    aws_s3_bucket.django_storage
  ]

}

############################################
# IAM User for Django S3 Access
############################################
resource "aws_iam_user" "django_s3_user" {
  name = "${var.environment}-django-s3-user"
  tags = local.common_tags
}

# Create access keys for the IAM user
resource "aws_iam_access_key" "django_s3_user" {
  user = aws_iam_user.django_s3_user.name
}

# S3 bucket policy for Django user
resource "aws_iam_user_policy" "django_s3_policy" {
  name = "django-s3-access"
  user = aws_iam_user.django_s3_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.django_storage.arn,
          "${aws_s3_bucket.django_storage.arn}/*"
        ]
      }
    ]
  })

  depends_on = [
    aws_s3_bucket.django_storage,
    aws_iam_user.django_s3_user
  ]

}

############################################
# Create Kubernetes Secret for S3 Credentials
############################################
resource "kubernetes_secret" "django_s3_credentials" {
  metadata {
    name      = "django-s3-credentials"
    namespace = "default"
  }

  data = {
    AWS_S3_ACCESS_KEY_ID     = aws_iam_access_key.django_s3_user.id
    AWS_S3_SECRET_ACCESS_KEY = aws_iam_access_key.django_s3_user.secret
    AWS_STORAGE_BUCKET_NAME  = aws_s3_bucket.django_storage.id
    AWS_S3_REGION_NAME       = var.aws_region
    AWS_S3_SIGNATURE_VERSION = "s3v4"
  }

  depends_on = [
    aws_s3_bucket.django_storage,
    aws_iam_access_key.django_s3_user,
    module.eks.worker_nodes
  ]
}