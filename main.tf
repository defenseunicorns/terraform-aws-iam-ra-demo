locals {
  trust_anchor_arns = values(aws_rolesanywhere_trust_anchor.all-dod-id-ca)[*].arn
  npe_trust_anchor_arns = values(aws_rolesanywhere_trust_anchor.npe-root-ca)[*].arn
}

resource "aws_rolesanywhere_trust_anchor" "all-dod-id-ca" {
  for_each = var.trust_anchors

  enabled = true
  name = each.value.name
  source {
    source_data {
      x509_certificate_data = each.value.x509_certificate_data
    }
    source_type = "CERTIFICATE_BUNDLE"
  }
}

resource "aws_rolesanywhere_trust_anchor" "npe-root-ca" {
  for_each = var.npe_trust_anchor

  enabled = true
  name = each.value.name
  source {
    source_data {
      x509_certificate_data = each.value.x509_certificate_data
    }
    source_type = "CERTIFICATE_BUNDLE"
  }
}

resource "aws_iam_role" "priv_user" {

  name                 = var.priv_role_name
  assume_role_policy = data.aws_iam_policy_document.cac_role_trust_relationship_priv_users.json
}

resource "aws_iam_role" "standard_user" {

  name                 = var.standard_role_name
  assume_role_policy = data.aws_iam_policy_document.cac_role_trust_relationship_standard_users.json
}

resource "aws_iam_role" "npe_client" {

  name                 = var.npe_role_name
  assume_role_policy = data.aws_iam_policy_document.npe_role_trust_relationship_clients.json
}

resource "aws_rolesanywhere_profile" "priv-users" {

  name      = var.priv_rolesanywhere_profile_name
  role_arns = [aws_iam_role.priv_user.arn]
  enabled   = true
}

resource "aws_rolesanywhere_profile" "standard-users" {

  name      = var.standard_rolesanywhere_profile_name
  role_arns = [aws_iam_role.standard_user.arn]
  enabled   = true
}

resource "aws_rolesanywhere_profile" "npe-clients" {

  name      = var.npe_rolesanywhere_profile_name
  role_arns = [aws_iam_role.npe_client.arn]
  enabled   = true
}

#assign admin permissions to priv user
resource "aws_iam_role_policy_attachment" "priv-attach" {
  role       = aws_iam_role.priv_user.name
  policy_arn = data.aws_iam_policy.administrator_access.arn
}

#assign granular permissions to standard user
data "aws_iam_policy_document" "policy" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::*"]
  }
}

resource "aws_iam_policy" "policy" {
  name        = var.policy_name
  description = "A test policy for EC2 and S3 access"
  policy      = data.aws_iam_policy_document.policy.json
}

resource "aws_iam_role_policy_attachment" "standard-attach" {
  role       = aws_iam_role.standard_user.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_role_policy_attachment" "npe-attach" {
  role       = aws_iam_role.npe_client.name
  policy_arn = aws_iam_policy.policy.arn
}
