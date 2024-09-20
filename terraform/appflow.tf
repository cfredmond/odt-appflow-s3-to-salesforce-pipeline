resource "aws_appflow_flow" "odt_aws_to_s3_flow" {
  name = "odt-aws-to-s3-${var.environment}"

  source_flow_config {
    connector_type = "S3"
    source_connector_properties {
      s3 {
        bucket_name   = aws_s3_bucket.odt_source_dev.bucket
        bucket_prefix = var.source_bucket_prefix
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