variable "trust_anchors" {
  type = map(object({
    name                = string
    x509_certificate_data = string
  }))
  default = {
    "anchor1" = {
      name                = "trust-anchor-1"
      x509_certificate_data = "..."
    },
    "anchor2" = {
      name                = "trust-anchor-2"
      x509_certificate_data = "..."
    },
    # Add more trust anchor definitions as needed
  }
}

variable "npe_trust_anchor" {
  type = map(object({
    name                = string
    x509_certificate_data = string
  }))
  default = {
    "anchor" = {
      name                = "trust-anchor-npe"
      x509_certificate_data = "..."
    }
  }
}

variable "cert_common_names_priv_users" {
  type    = list(string)
  default = [""]  # Replace with your common names
}

variable "cert_common_names_standard_users" {
  type    = list(string)
  default = [""]  # Replace with your common names
}

variable "policy_name" {
  description = "Name of the policy to be created for standard users & npe clients"
  type        = string
  default     = "test-policy-iam"
}

variable "priv_role_name" {
  description = "Name of the role to be created for privileged users"
  type        = string
  default     = "priv-user-role"
}

variable "standard_role_name" {
  description = "Name of the role to be created for standard users"
  type        = string
  default     = "standard-user-role"
}

variable "npe_role_name" {
  description = "Name of the role to be created for npe clients"
  type        = string
  default     = "npe-client-role"
}

variable "priv_rolesanywhere_profile_name" {
  description = "Name of the profile to be created for privileged users"
  type        = string
  default     = "priv-user-profile"
}

variable "standard_rolesanywhere_profile_name" {
  description = "Name of the profile to be created for standard users"
  type        = string
  default     = "standard-user-profile"
}

variable "npe_rolesanywhere_profile_name" {
  description = "Name of the profile to be created for npe clients"
  type        = string
  default     = "npe-client-profile"
}