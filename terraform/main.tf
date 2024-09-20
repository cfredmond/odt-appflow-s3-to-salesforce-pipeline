resource "aws_s3_bucket" "odt_source_dev" {
  bucket = "odt-source-dev-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "odt-source-dev"
    Environment = "dev"
    Project     = "odt"
    ManagedBy   = "Terraform"
  }
}

resource "random_string" "bucket_suffix" {
  length  = 6
  special = false
  upper   = false
}

output "odt_source_s3_bucket_name" {
  value       = aws_s3_bucket.odt_source_dev.bucket
  description = "The name of the ODT source S3 bucket (Dev environment)"
}

data "aws_iam_policy_document" "odt_source" {
  statement {
    sid    = "AllowAppFlowSourceActions"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["appflow.amazonaws.com"]
    }
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]
    resources = [
      aws_s3_bucket.odt_source_dev.arn,
      "${aws_s3_bucket.odt_source_dev.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "odt_source_policy" {
  bucket = aws_s3_bucket.odt_source_dev.id
  policy = data.aws_iam_policy_document.odt_source.json
}

resource "aws_s3_object" "odt_source_object" {
  bucket = aws_s3_bucket.odt_source_dev.id
  key    = "odt-source-dev-data.csv"
  source = "odt-source-dev-data.csv"
}

resource "aws_s3_bucket" "odt_destination_dev" {
  bucket = "odt-destination-dev-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "odt-destination-dev"
    Environment = "dev"
    Project     = "odt"
    ManagedBy   = "Terraform"
  }
}

output "odt_destination_s3_bucket_name" {
  value       = aws_s3_bucket.odt_destination_dev.bucket
  description = "The name of the ODT destination S3 bucket (Dev environment)"
}

data "aws_iam_policy_document" "odt_destination" {
  statement {
    sid    = "AllowAppFlowDestinationActions"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["appflow.amazonaws.com"]
    }
    actions = [
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
      "s3:ListBucketMultipartUploads",
      "s3:GetBucketAcl",
      "s3:PutObjectAcl",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.odt_destination_dev.arn,
      "${aws_s3_bucket.odt_destination_dev.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "odt_destination_policy" {
  bucket = aws_s3_bucket.odt_destination_dev.id
  policy = data.aws_iam_policy_document.odt_destination.json
}

resource "aws_appflow_flow" "odt_aws_to_s3_flow" {
  name = "odt-aws-to-s3-dev"

  source_flow_config {
    connector_type = "S3"
    source_connector_properties {
      s3 {
        bucket_name   = aws_s3_bucket.odt_source_dev.bucket
        bucket_prefix = "odt-source-dev-data.csv"
      }
    }
  }

  destination_flow_config {
    connector_type = "S3"
    destination_connector_properties {
      s3 {
        bucket_name = aws_s3_bucket.odt_destination_dev.bucket

        s3_output_format_config {
          prefix_config {
            prefix_type = "PATH"
          }
        }
      }
    }
  }

  task {
    source_fields = ["CustomerID", "FirstName", "LastName", "Email", "Phone"]
    task_type     = "Filter"
    connector_operator {
      s3 = "PROJECTION"
    }
  }

  task {
    source_fields     = ["CustomerID"]
    destination_field = "CustomerID"
    task_type         = "Map"
    connector_operator {
      s3 = "NO_OP"
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

  trigger_config {
    trigger_type = "OnDemand"
  }
}