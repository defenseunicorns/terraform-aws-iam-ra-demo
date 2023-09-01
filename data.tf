data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_policy" "administrator_access" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy_document" "cac_role_trust_relationship_priv_users" {

  dynamic "statement" {
    for_each = toset(var.cert_common_names_priv_users)

    content {
			principals {
				type = "Service"
				identifiers = [
					"rolesanywhere.amazonaws.com"
				]
			}

			actions = [
				"sts:AssumeRole",
				"sts:TagSession",
				"sts:SetSourceIdentity",
			]

			condition {
				test = "StringEquals"
				variable = "aws:PrincipalTag/x509Subject/CN"
				values = [statement.key]
			}

			condition {
				test = "ArnEquals"
				variable = "aws:SourceArn"
				values = local.trust_anchor_arns
			}

			condition {
				test = "StringEquals"
				variable = "aws:PrincipalTag/x509Subject/O"
				values = ["U.S. Government"]
			}

			condition {
				test = "StringEquals"
				variable = "aws:PrincipalTag/x509Issuer/C"
				values = ["US"]
			}

			condition {
				test = "StringEquals"
				variable = "aws:PrincipalTag/x509Subject/C"
				values = ["US"]
			}

			condition {
				test = "StringEquals"
				variable = "aws:PrincipalTag/x509Issuer/O"
				values = ["U.S. Government"]
			}

			condition {
				test = "StringEquals"
				variable = "aws:PrincipalTag/x509Issuer/OU"
				values = ["DoD/PKI"]
			}

			condition {
				test = "StringLike"
				variable = "aws:PrincipalTag/x509Issuer/CN"
				values = ["DOD ID CA-*"]
			}
		}
	}
}

data "aws_iam_policy_document" "cac_role_trust_relationship_standard_users" {

  dynamic "statement" {
    for_each = toset(var.cert_common_names_standard_users)

    content {
      principals {
      type = "Service"
      identifiers = [
          "rolesanywhere.amazonaws.com"
      ]
      }

      actions = [
      "sts:AssumeRole",
      "sts:TagSession",
      "sts:SetSourceIdentity",
      ]

      condition {
      test = "StringEquals"
      variable = "aws:PrincipalTag/x509Subject/CN"
      values = [statement.key]
      }

      condition {
      test = "ArnEquals"
      variable = "aws:SourceArn"
      values = local.trust_anchor_arns
      }

      condition {
      test = "StringEquals"
      variable = "aws:PrincipalTag/x509Subject/O"
      values = ["U.S. Government"]
      }

      condition {
      test = "StringEquals"
      variable = "aws:PrincipalTag/x509Issuer/C"
      values = ["US"]
      }

      condition {
      test = "StringEquals"
      variable = "aws:PrincipalTag/x509Subject/C"
      values = ["US"]
      }

      condition {
      test = "StringEquals"
      variable = "aws:PrincipalTag/x509Issuer/O"
      values = ["U.S. Government"]
      }

      condition {
      test = "StringEquals"
      variable = "aws:PrincipalTag/x509Issuer/OU"
      values = ["DoD/PKI"]
      }

      condition {
      test = "StringLike"
      variable = "aws:PrincipalTag/x509Issuer/CN"
      values = ["DOD ID CA-*"]
      }
		}
	}
}

data "aws_iam_policy_document" "npe_role_trust_relationship_clients" {

  	statement {

		principals {
			type = "Service"
			identifiers = [
				"rolesanywhere.amazonaws.com"
			]
		}

		actions = [
			"sts:AssumeRole",
			"sts:TagSession",
			"sts:SetSourceIdentity",
		]

		condition {
			test = "StringEquals"
			variable = "aws:PrincipalTag/x509Issuer/CN"
			values = ["rootca.bigbang.dev"]
		}
		condition {
			test = "StringEquals"
			variable = "aws:PrincipalTag/x509Subject/CN"
			values = ["aws-client1.bigbang.dev"]
		}

		condition {
			test = "ArnEquals"
			variable = "aws:SourceArn"
			values = local.npe_trust_anchor_arns
		}
	}
}
