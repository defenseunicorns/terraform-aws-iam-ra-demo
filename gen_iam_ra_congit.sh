#!/bin/zsh

if [[ $# -eq 0 ]] 
  then
    echo "Please pass AWS Config path and file to update"
    exit 1
fi

# Location of the AWS IAM Rolesanywhere Credential Helper 
helper_dir="/Users/johntrapnell/tools"
# Where the location of the test NPE cert  amd private key are located
cert_dir="/Users/johntrapnell/settings/Certificates"

region=$(aws configure get region 2>/dev/null)
acct_num=$(aws sts get-caller-identity --query "Account" --output text 2>/dev/null)

npe_ta_id=$(aws rolesanywhere list-trust-anchors --query "trustAnchors[?name=='NPE Root CA cert'].trustAnchorId" --output text 2>/dev/null)
npe_prof_id=$(aws rolesanywhere list-profiles --query "profiles[?name=='npe-client-profile'].profileId" --output text 2>/dev/null)

echo "" >> $1
echo "[profile npe_test]" >> $1
echo "credential_process = ${helper_dir}/aws_signing_helper credential-process --certificate ${cert_dir}/aws-client1-cert.pem --private-key ${cert_dir}/aws-client1-private.pem --trust-anchor-arn arn:aws:rolesanywhere:${region}:${acct_num}:trust-anchor/${npe_ta_id} --profile-arn arn:aws:rolesanywhere:${region}:${acct_num}:profile/${npe_prof_id} --role-arn arn:aws:iam::${acct_num}:role/npe-client-role" >> $1

cac_ta_id=$(aws rolesanywhere list-trust-anchors --query "trustAnchors[?name=='DoD ID CA 64-65'].trustAnchorId" --output text 2>/dev/null)
cac_prof_id=$(aws rolesanywhere list-profiles --query "profiles[?name=='standard-user-profile'].profileId" --output text 2>/dev/null)

echo "" >> $1
echo "[profile cac_test]" >> $1
echo "credential_process = ${helper_dir}/aws_signing_helper credential-process --cert-selector 'Key=x509Serial,Value=1634A3' --trust-anchor-arn arn:aws:rolesanywhere:${region}:${acct_num}:trust-anchor/${cac_ta_id} --profile-arn arn:aws:rolesanywhere:${region}:${acct_num}:profile/${cac_prof_id} --role-arn arn:aws:iam::${acct_num}:role/standard-user-role" >> $1

