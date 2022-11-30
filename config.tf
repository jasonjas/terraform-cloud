resource "aws_config_config_rule" "tags" {
  name = "require-tags"

  source {
    owner             = "AWS"
    source_identifier = "required-tags"
  }

    input_parameters = <<PARAMETERS
{
  "tag1Key": "Name",
  "tag2Key": "environment"
}
PARAMETERS

  depends_on = [aws_config_configuration_recorder.config_recorder]
}

# -----------------------------------------------------------
# set up the AWS IAM Role to assign to AWS Config Service
# -----------------------------------------------------------
resource "aws_iam_role" "config_role" {
  name = "awsconfig-example"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "config_policy_attach" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_iam_role_policy_attachment" "read_only_policy_attach" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/ReadOnlyAccess"
}

# -----------------------------------------------------------
# set up the AWS Config Recorder
# -----------------------------------------------------------
resource "aws_config_configuration_recorder" "config_recorder" {

  name     = "config_recorder"
  role_arn = aws_iam_role.config_role.arn
  recording_group {
    all_supported  = false
    resource_types = ["AWS::ElasticBeanstalk::Application"]
  }
}

# -----------------------------------------------------------
# Set up Delivery channel resource and bucket location to specify configuration history location.
# -----------------------------------------------------------
resource "aws_config_delivery_channel" "config_channel" {
  s3_bucket_name = aws_s3_bucket.new_config_bucket.id
  depends_on     = [aws_config_configuration_recorder.config_recorder]
}

# -----------------------------------------------------------
# Enable AWS Config Recorder
# -----------------------------------------------------------
resource "aws_config_configuration_recorder_status" "config_recorder_status" {
  name       = aws_config_configuration_recorder.config_recorder.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.config_channel]
}