resource "aws_s3_bucket" "odt_source_dev" {
  bucket = "odt-source-${var.environment}-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "odt-source-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}

resource "aws_s3_object" "odt_source_object" {
  bucket = aws_s3_bucket.odt_source_dev.id
  key    = var.source_bucket_prefix
  source = var.source_bucket_prefix
}

resource "aws_s3_bucket" "odt_destination_dev" {
  bucket = "odt-destination-${var.environment}-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "odt-destination-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = var.managed_by
  }
}