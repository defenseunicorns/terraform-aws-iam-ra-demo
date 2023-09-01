# aws-iam-rolesanywhere

## Purpose

This project is to stand up an example of using AWS IAM Roles Anywhere to support both NPE (non-person entity) and a client or user being granted temporary security credentials to control AWS resources in the given cluster.

## What is Created

- A Trust Anchor for an example root CA Cert for Big Bang. This is what example test certs can be created from
- Trust Anchors for the DOD ID CA 62 through 65 (Intermediate Certificate Authority). The ones the CAC certs are issued from
- A custom permissions policy to specify some basic capabilities on EC2 and S3 buckets (for demo purposes)
- Roles
  - NPE client (with the trust policy for client certs defined in data.tf and the above permissions attached)
  - For standard users (with the trust policy for standard user CAC info defined in data.tf and the above permissions attached)
  - For privileged users (with the trust policy for privileged user CAC info defined in data.tf and AdministratorAccess policy attached)
- A NPE client profile with the NPE Client role above attached to it
- A standard user profile with the standard users role above attached to it
- A privileged user profile with the privileged users role above attached to it

## What needs to be updated to plan/apply

- Use example.tfvars to create your own test vars file:
  - Add other DOD ID CA intermediate or CAroot certs to the list
  - Enter actual user CAC PIV cert data for the CN's you want to use
  - Uncomment any overrides on the name of artifacts create to avoid naming collisions
- Update the data.tf to update any of the trust relationship specs or add/change custom created certs to the 'npe_role_trust_relationship_clients' x509Subject/CN to match on
