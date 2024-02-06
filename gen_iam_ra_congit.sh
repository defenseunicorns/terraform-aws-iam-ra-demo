#!/bin/zsh

if [[ $# -eq 0 ]] 
  then
    echo "Please pass AWS Config path and file to update"
    exit 1
fi

# Where the location of the test NPE cert  amd private key are located
cert_dir="/Users/johntrapnell/settings/Certificates"

#cert_txt=$(pkcs11-tool --list-objects --type cert | grep -B 1 -A 3 "Certificate for PIV Authentication" 2>/dev/null)
cert_txt=$(pkcs15-tool --list-certificates | grep -B 1 -A 5 "Certificate for PIV Authentication")
cert_id=$(echo "${cert_txt}" | awk '/ID:/ {print $2}' 2>/dev/null)
echo "Cert ID: ${cert_id}"
serial=$(echo "${cert_txt}" | awk '/serial:/ {print $2}' 2>/dev/null)
echo "Cert Serial: ${serial}"
sleep 5
#issuer=$(pkcs11-tool --read-object --type cert --id "${cert_id}" | openssl x509 -inform DER  -text -noout -issuer | grep 'Issuer:' 2>/dev/null)
issuer=$(pkcs15-tool --read-certificate 01 | openssl x509 -text -noout | grep 'Issuer:' 2>/dev/null)
#issuer="        Issuer: C=US, O=U.S. Government, OU=DoD, OU=PKI, CN=DOD ID CA-65"
echo "Issuer: ${issuer}"
cert_name=$(echo "${issuer}" | awk -F ', ' '{for(i=1; i<=NF; i++) if ($i ~ /^CN=/) print substr($i, 4)}' | awk '{ gsub(/[ -]/, "_"); print }' 2>/dev/null)
echo "Cert: ${cert_name}"

#region=$(aws configure get region 2>/dev/null)
#acct_num=$(aws sts get-caller-identity --query "Account" --output text 2>/dev/null)

npe_ta_arn=$(aws rolesanywhere list-trust-anchors --query "trustAnchors[?name=='NPE Root CA cert'].trustAnchorArn" --output text 2>/dev/null)
npe_prof_arn=$(aws rolesanywhere list-profiles --query "profiles[?name=='npe-client-profile'].profileArn" --output text 2>/dev/null)
npe_role_arn=$(aws iam list-roles --query "Roles[?RoleName=='npe-client-role'].Arn" --output text 2>/dev/null)
echo "NPE Trust: ${npe_ta_arn}"
echo "NPE Profile: ${npe_prof_arn}"
echo "NPE Role: ${npe_role_arn}"

echo "" >> $1
echo "[profile npe_test]" >> $1
echo "credential_process = aws_signing_helper credential-process --certificate ${cert_dir}/aws-client1-cert.pem --private-key ${cert_dir}/aws-client1-private.pem --trust-anchor-arn ${npe_ta_arn} --profile-arn ${npe_prof_arn} --role-arn ${npe_role_arn}" >> $1

cac_ta_arn=$(aws rolesanywhere list-trust-anchors --query "trustAnchors[?name=='DoD ID CA 64-65'].trustAnchorArn" --output text 2>/dev/null)
cac_prof_arn=$(aws rolesanywhere list-profiles --query "profiles[?name=='standard-user-profile'].profileArn" --output text 2>/dev/null)
cac_role_arn=$(aws iam list-roles --query "Roles[?RoleName=='standard-user-role'].Arn" --output text 2>/dev/null)
echo "CAC Trust arn: ${cac_ta_arn}"
echo "CAC Profile arn: ${cac_prof_arn}"
echo "CAC Role: ${cac_role_arn}"

echo "" >> $1
echo "[profile cac_test]" >> $1
echo "credential_process = aws_signing_helper credential-process --cert-selector 'Key=x509Serial,Value=${serial}' --trust-anchor-arn ${cac_ta_arn} --profile-arn ${cac_prof_arn} --role-arn ${cac_role_arn}" >> $1
