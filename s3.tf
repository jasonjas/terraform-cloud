# -----------------------------------------------------------
# Create AWS S3 bucket for AWS Config to record configuration history and snapshots
# -----------------------------------------------------------
resource "aws_s3_bucket" "new_config_bucket" {
  bucket        = "config-bucket-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "new_config_bucket" {
  bucket = aws_s3_bucket.new_config_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "new_config_bucket" {
  bucket = aws_s3_bucket.new_config_bucket.bucket
  acl    = "private"
}

# -----------------------------------------------------------
# Define AWS S3 bucket policies
# -----------------------------------------------------------
# resource "aws_s3_bucket_policy" "config_logging_policy" {
#   bucket = aws_s3_bucket.new_config_bucket.id
#   policy = jsonencode(
#     {
#       Statement = [
#         {
#           Action = "s3:GetBucketAcl"
#           Condition = {
#             StringEquals = {
#               "AWS:SourceAccount" = "528262653046"
#             }
#           }
#           Effect = "Allow"
#           Principal = {
#             Service = "config.amazonaws.com"
#           }
#           Resource = "arn:aws:s3:::config-bucket-528262653046"
#           Sid      = "AWSConfigBucketPermissionsCheck"
#         },
#         {
#           Action = "s3:ListBucket"
#           Condition = {
#             StringEquals = {
#               "AWS:SourceAccount" = "528262653046"
#             }
#           }
#           Effect = "Allow"
#           Principal = {
#             Service = "config.amazonaws.com"
#           }
#           Resource = "arn:aws:s3:::config-bucket-528262653046"
#           Sid      = "AWSConfigBucketExistenceCheck"
#         },
#         {
#           Action = "s3:PutObject"
#           Condition = {
#             StringEquals = {
#               "AWS:SourceAccount" = "528262653046"
#               "s3:x-amz-acl"      = "bucket-owner-full-control"
#             }
#           }
#           Effect = "Allow"
#           Principal = {
#             Service = "config.amazonaws.com"
#           }
#           Resource = "arn:aws:s3:::config-bucket-528262653046/AWSLogs/528262653046/Config/*"
#           Sid      = "AWSConfigBucketDelivery"
#         },
#       ]
#       Version = "2012-10-17"
#     }
#   )
# }


# -----------------------------------------------------------
# Define AWS S3 bucket policies
# -----------------------------------------------------------
resource "aws_s3_bucket_policy" "config_logging_policy" {
  bucket = aws_s3_bucket.new_config_bucket.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowBucketAcl",
      "Effect": "Allow",
      "Principal": {
        "Service": [
         "config.amazonaws.com"
        ]
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "${aws_s3_bucket.new_config_bucket.arn}",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "true"
        }
      }
    },
    {
      "Sid": "AllowConfigWriteAccess",
      "Effect": "Allow",
      "Principal": {
        "Service": [
         "config.amazonaws.com"
        ]
      },
      "Action": "s3:PutObject",
      "Resource": "${aws_s3_bucket.new_config_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        },
        "Bool": {
          "aws:SecureTransport": "true"
        }
      }
    },
    {
      "Sid": "RequireSSL",
      "Effect": "Deny",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:*",
      "Resource": "${aws_s3_bucket.new_config_bucket.arn}/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
POLICY
}