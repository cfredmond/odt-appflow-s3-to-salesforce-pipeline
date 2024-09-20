data "aws_iam_policy_document" "odt_source" {
  statement {
    sid    = "AllowAppFlowSourceActions"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = [var.appflow_service_principal]
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

data "aws_iam_policy_document" "odt_destination" {
  statement {
    sid    = "AllowAppFlowDestinationActions"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = [var.appflow_service_principal]
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