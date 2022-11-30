# Organization Setup
# resource "aws_organizations_organization" "this" {
#   aws_service_access_principals = [
#     "config.amazonaws.com",
#     "config-multiaccountsetup.amazonaws.com",
#     "controltower.amazonaws.com",
#     "fms.amazonaws.com",
#     "guardduty.amazonaws.com",
#     "member.org.stacksets.cloudformation.amazonaws.com",
#     "reporting.trustedadvisor.amazonaws.com",
#     "sso.amazonaws.com",
#     "securityhub.amazonaws.com",
#   ]

#   enabled_policy_types = [
#     "SERVICE_CONTROL_POLICY",
#   ]

#   feature_set = "ALL"
# }

# Administrator account delegation
# resource "aws_securityhub_organization_admin_account" "this" {
#   depends_on = [aws_organizations_organization.this]

#   admin_account_id = data.aws_caller_identity.current.account_id
# }