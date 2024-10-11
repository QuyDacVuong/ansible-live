#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

cd "$(dirname "$0")"

if [ $# -lt 3 ]; then
    >&2 echo "No environment provided. Usage: ./start_zone1.sh <env> <winrm_user> <winrm_password>"
    >&2 echo "<env> =  [development | qa1 | preprod]"
    >&2 echo "<winrm_username> = [system_user_name]"
    >&2 echo "<winrm_password> = [system_password]"
    exit 1
fi

HOSTSFILE="../windows_aws_ec2.yml"
CONN_VARS="env=$1 ansible_user=$2 ansible_password=$3"


echo "⚠️ This will START pyr services on all Windows servers in $1 zone 1 ⚠️"
echo

start_win_service () {
  echo "Authenticating..$1 and Starting Service $2"
  ansible -i $HOSTSFILE $1 -m ansible.windows.win_service -a "name=$2 state=started" -e "$CONN_VARS"
}

start_win_service role_ggn_concentrator PYR_C_CONCENTRATOR
start_win_service role_ggn_gdk PYR_C_GDK
start_win_service role_ggn_non_gdk PYR_C_TABLES
start_win_service role_ggn_lobby PYR_C_LOBBY
start_win_service role_ggn_lobby PYR_C_REEF_LOBBY
start_win_service role_ggn_lobby PYR_C_IP2COUNTRY
start_win_service role_ggn_oltp PYR_C_OLTP
start_win_service role_ggn_oltp PYR_C_REEF_OLTP
start_win_service role_ggn_oltp PYR_C_TOBRELAY
start_win_service role_ggn_data_feed_gw PYR_C_AUXUKGW

echo "ℹ️ Finished starting the $1 environment. Check for any failures above"
