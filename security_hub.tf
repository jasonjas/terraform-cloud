resource "aws_securityhub_account" "securityhub" {
  depends_on = [
    aws_config_configuration_recorder.config_recorder,
    aws_config_configuration_recorder_status.config_recorder_status
  ]
}

resource "aws_securityhub_standards_subscription" "cis_aws_foundations_benchmark" {
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
  depends_on    = [aws_securityhub_account.securityhub]
}

resource "aws_cloudformation_stack" "sharr_core" {
  name = "poc-sharr-core"

  template_body = file("${path.module}/security_hub/aws-sharr-deploy.template")

  parameters = {
    LoadAFSBPAdminStack       = "yes",
    LoadCIS120AdminStack      = "yes",
    LoadPCI321AdminStack      = "no",
    ReuseOrchestratorLogGroup = "no"
  }

  capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]

  tags = {
    "environment" = "test"
  }

  depends_on = [
    aws_securityhub_standards_subscription.cis_aws_foundations_benchmark
  ]
}

resource "aws_cloudformation_stack" "sharr_member" {
  name = "poc-sharr-member"

  template_body = file("${path.module}/security_hub/aws-sharr-member.template")

  parameters = {
    LogGroupName                          = "sharr-member-logs-${data.aws_caller_identity.current.id}",
    LoadAFSBPMemberStack                  = "yes",
    LoadCIS120MemberStack                 = "yes",
    LoadPCI321MemberStack                 = "no",
    CreateS3BucketForRedshiftAuditLogging = "no",
    SecHubAdminAccount                    = data.aws_caller_identity.current.id
  }

  capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]

  tags = {
    "environment" = "test"
  }

  depends_on = [
    aws_cloudformation_stack.sharr_core
  ]
}

resource "aws_cloudformation_stack" "sharr_member_roles" {
  name = "poc-sharr-member-roles"

  template_body = file("${path.module}/security_hub/aws-sharr-member-roles.template")

  parameters = {
    SecHubAdminAccount = data.aws_caller_identity.current.id
  }

  capabilities = ["CAPABILITY_NAMED_IAM"]

  tags = {
    "environment" = "test"
  }

  depends_on = [
    aws_cloudformation_stack.sharr_member
  ]
}