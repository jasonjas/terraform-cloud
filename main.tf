provider "aws" {
  region = "us-east-1"
}

#--------------
# S3 Variable
#--------------
variable "encryption_enabled" {
  type        = bool
  default     = true
  description = "When set to 'true' the resource will have AES256 encryption enabled by default"
}

# Get current region of Terraform stack
data "aws_region" "current" {}

# Get current account number
data "aws_caller_identity" "current" {}

# Retrieves the partition that it resides in
data "aws_partition" "current" {}

output "awsregion" {
  value = data.aws_region.current
}

output "awscaller" {
  value = data.aws_caller_identity.current
}

output "awspart" {
  value = data.aws_partition.current
}

# -----------------------------------------------------------
# set up the Conformance Pack
# -----------------------------------------------------------
# resource "aws_config_conformance_pack" "s3conformancepack" {
#   name = "s3conformancepack"

#   template_body = <<EOT

# Resources:
#   S3BucketPublicReadProhibited:
#     Type: AWS::Config::ConfigRule
#     Properties:
#       ConfigRuleName: S3BucketPublicReadProhibited
#       Description: >- 
#         Checks that your Amazon S3 buckets do not allow public read access.
#         The rule checks the Block Public Access settings, the bucket policy, and the
#         bucket access control list (ACL).
#       Scope:
#         ComplianceResourceTypes:
#         - "AWS::S3::Bucket"
#       Source:
#         Owner: AWS
#         SourceIdentifier: S3_BUCKET_PUBLIC_READ_PROHIBITED
#       MaximumExecutionFrequency: Six_Hours
#   S3BucketPublicWriteProhibited: 
#     Type: "AWS::Config::ConfigRule"
#     Properties: 
#       ConfigRuleName: S3BucketPublicWriteProhibited
#       Description: "Checks that your Amazon S3 buckets do not allow public write access. The rule checks the Block Public Access settings, the bucket policy, and the bucket access control list (ACL)."
#       Scope: 
#         ComplianceResourceTypes: 
#         - "AWS::S3::Bucket"
#       Source: 
#         Owner: AWS
#         SourceIdentifier: S3_BUCKET_PUBLIC_WRITE_PROHIBITED
#       MaximumExecutionFrequency: Six_Hours
#   S3BucketReplicationEnabled: 
#     Type: "AWS::Config::ConfigRule"
#     Properties: 
#       ConfigRuleName: S3BucketReplicationEnabled
#       Description: "Checks whether the Amazon S3 buckets have cross-region replication enabled."
#       Scope: 
#         ComplianceResourceTypes: 
#         - "AWS::S3::Bucket"
#       Source: 
#         Owner: AWS
#         SourceIdentifier: S3_BUCKET_REPLICATION_ENABLED
#   S3BucketSSLRequestsOnly: 
#     Type: "AWS::Config::ConfigRule"
#     Properties: 
#       ConfigRuleName: S3BucketSSLRequestsOnly
#       Description: "Checks whether S3 buckets have policies that require requests to use Secure Socket Layer (SSL)."
#       Scope: 
#         ComplianceResourceTypes: 
#         - "AWS::S3::Bucket"
#       Source: 
#         Owner: AWS
#         SourceIdentifier: S3_BUCKET_SSL_REQUESTS_ONLY
#   ServerSideEncryptionEnabled: 
#     Type: "AWS::Config::ConfigRule"
#     Properties: 
#       ConfigRuleName: ServerSideEncryptionEnabled
#       Description: "Checks that your Amazon S3 bucket either has S3 default encryption enabled or that the S3 bucket policy explicitly denies put-object requests without server side encryption."
#       Scope: 
#         ComplianceResourceTypes: 
#         - "AWS::S3::Bucket"
#       Source: 
#         Owner: AWS
#         SourceIdentifier: S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED
#   S3BucketLoggingEnabled: 
#     Type: "AWS::Config::ConfigRule"
#     Properties: 
#       ConfigRuleName: S3BucketLoggingEnabled
#       Description: "Checks whether logging is enabled for your S3 buckets."
#       Scope: 
#         ComplianceResourceTypes: 
#         - "AWS::S3::Bucket"
#       Source: 
#         Owner: AWS
#         SourceIdentifier: S3_BUCKET_LOGGING_ENABLED

# EOT

#   depends_on = [aws_config_configuration_recorder.config_recorder]
# }