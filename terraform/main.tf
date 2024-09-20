resource "aws_s3_bucket" "odt_source_dev" {
  bucket = "odt-source-dev-${random_string.bucket_suffix.result}"
  # acl    = "private"  # Keep the bucket private for security

  tags = {
    Name        = "odt-source-dev"
    Environment = "dev"
    Project     = "odt"
    ManagedBy   = "Terraform"
  }
}

# Random string for unique bucket name suffix
resource "random_string" "bucket_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Outputs to display after bucket creation
output "odt_source_s3_bucket_name" {
  value = aws_s3_bucket.odt_source_dev.bucket
  description = "The name of the ODT source S3 bucket (Dev environment)"
}

# IAM policy document for allowing AppFlow actions on the ODT source bucket
data "aws_iam_policy_document" "odt_source" {
  statement {
    sid    = "AllowAppFlowSourceActions"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["appflow.amazonaws.com"]
    }

    actions = [
      "s3:ListBucket",  # Permission to list the bucket
      "s3:GetObject",   # Permission to get objects in the bucket
    ]

    resources = [
      aws_s3_bucket.odt_source_dev.arn,        # Reference the source bucket's ARN
      "${aws_s3_bucket.odt_source_dev.arn}/*", # Grant access to all objects in the bucket
    ]
  }
}

# Apply the policy to the source S3 bucket
resource "aws_s3_bucket_policy" "odt_source_policy" {
  bucket = aws_s3_bucket.odt_source_dev.id  # Reference the source bucket

  policy = data.aws_iam_policy_document.odt_source.json
}

resource "aws_s3_object" "odt_source_object" {
  bucket = aws_s3_bucket.odt_source_dev.id  # Reference the source S3 bucket
  key    = "odt-source-dev-data.csv"
  source = "odt-source-dev-data.csv"
}

# S3 bucket for ODT destination in the Salesforce pipeline (Dev environment)
resource "aws_s3_bucket" "odt_destination_dev" {
  bucket = "odt-destination-dev-${random_string.bucket_suffix.result}"
  # acl    = "private"  # Keep the bucket private for security

  tags = {
    Name        = "odt-destination-dev"
    Environment = "dev"
    Project     = "odt"
    ManagedBy   = "Terraform"
  }
}

# Outputs to display after bucket creation
output "odt_destination_s3_bucket_name" {
  value       = aws_s3_bucket.odt_destination_dev.bucket
  description = "The name of the ODT destination S3 bucket (Dev environment)"
}

# IAM policy document for allowing AppFlow actions on the ODT destination bucket with a single statement
data "aws_iam_policy_document" "odt_destination" {
  statement {
    sid    = "AllowAppFlowDestinationActions"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["appflow.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",                  # Allow putting objects in the bucket
      "s3:AbortMultipartUpload",        # Allow aborting multipart uploads
      "s3:ListMultipartUploadParts",    # Allow listing multipart upload parts
      "s3:ListBucketMultipartUploads",  # Allow listing multipart uploads
      "s3:GetBucketAcl",                # Allow getting the bucket ACL
      "s3:PutObjectAcl",                # Allow setting the ACL on objects
      "s3:ListBucket",                  # Allow listing the bucket itself
    ]

    resources = [
      aws_s3_bucket.odt_destination_dev.arn,        # Grant access to the bucket
      "${aws_s3_bucket.odt_destination_dev.arn}/*",  # Grant access to all objects in the bucket
    ]
  }
}

# Apply the policy to the destination S3 bucket
resource "aws_s3_bucket_policy" "odt_destination_policy" {
  bucket = aws_s3_bucket.odt_destination_dev.id  # Reference the destination bucket

  policy = data.aws_iam_policy_document.odt_destination.json
}


resource "aws_appflow_flow" "odt_aws_to_s3_flow" {
  name = "odt-aws-to-s3-dev"

  # Source Configuration (S3)
  source_flow_config {
    connector_type = "S3"
    source_connector_properties {
      s3 {
        bucket_name   = aws_s3_bucket.odt_source_dev.bucket  # Reference the ODT source bucket
        bucket_prefix = "odt-source-dev-data.csv"            # CSV file as source
      }
    }
  }

  # Destination Configuration (S3)
  destination_flow_config {
    connector_type = "S3"
    destination_connector_properties {
      s3 {
        bucket_name = aws_s3_bucket.odt_destination_dev.bucket  # Reference the ODT destination bucket

        s3_output_format_config {
          prefix_config {
            prefix_type = "PATH"  # The destination path prefix type
          }
        }
      }
    }
  }

  # FilterTask to project source fields
  task {
    source_fields = ["CustomerID", "FirstName", "LastName", "Email", "Phone"]  # Project all source fields
    task_type     = "Filter"  # This task projects fields from the source data

    connector_operator {
      s3 = "PROJECTION"  # Filter task that determines the fields to project
    }
  }

  # Mapping Tasks (One-to-One Mapping for Each Field)
  task {
    source_fields     = ["CustomerID"]
    destination_field = "CustomerID"
    task_type         = "Map"

    connector_operator {
      s3 = "NO_OP"  # No transformation on the data
    }
  }

  task {
    source_fields     = ["FirstName"]
    destination_field = "FirstName"
    task_type         = "Map"

    connector_operator {
      s3 = "NO_OP"
    }
  }

  task {
    source_fields     = ["LastName"]
    destination_field = "LastName"
    task_type         = "Map"

    connector_operator {
      s3 = "NO_OP"
    }
  }

  task {
    source_fields     = ["Email"]
    destination_field = "Email"
    task_type         = "Map"

    connector_operator {
      s3 = "NO_OP"
    }
  }

  task {
    source_fields     = ["Phone"]
    destination_field = "Phone"
    task_type         = "Map"

    connector_operator {
      s3 = "NO_OP"
    }
  }

  # Trigger Configuration
  trigger_config {
    trigger_type = "OnDemand"  # Flow will be triggered manually
  }
}