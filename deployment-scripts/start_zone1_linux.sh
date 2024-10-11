#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

cd "$(dirname "$0")"

if [ $# -eq 0 ]; then
    >&2 echo "No environment provided. Usage: ./start_zone1_linux.sh <env>"
    >&2 echo "<env> =  [development | qa1 | preprod | prod]"
    exit 1
fi

HOSTSFILE="../aws_ec2.yml"

if [ $1 == 'development' ]; then
    CONN_VARS="env=development ansible_aws_ssm_bucket_name=ggn-uki-infra-zone1-development-ansible-ssm"
elif [ $1 == 'qa1' ]; then
    CONN_VARS="env=qa1 ansible_aws_ssm_bucket_name=ggn-uki-infra-zone1-qa1-ansible-ssm"
elif [ $1 == 'preprod' ]; then
    CONN_VARS="env=preprod ansible_aws_ssm_bucket_name=ggn-uki-infra-zone1-preprod-ansible-ssm"
elif [ $1 == 'prod' ]; then
    CONN_VARS="env=prod ansible_aws_ssm_bucket_name=ggn-uki-infra-zone1-prod-ansible-ssm"
fi


echo "⚠️ This will START services on all Linux servers in $1 zone 1 ⚠️"
echo

start_service () {
  echo "Authenticating..$1 and Starting Service $2"
  ansible -i $HOSTSFILE $1 -m ansible.builtin.service -a "name=$2 state=started" -e "$CONN_VARS"
}

start_service role_ggn_cipwa pyr_tomcat_cipwa
start_service role_ggn_entropy pyr_C_RNGEntropy
start_service role_ggn_demo_back_office pyr_tomcat_ggndemobackoffice
start_service role_ggn_ppb_integration_gw pyr_tomcat_ppbintegration
start_service role_ggn_sbg_integration_gw pyr_tomcat_sbgintegration

echo "ℹ️ Finished starting the $1 environment. Check for any failures above"
