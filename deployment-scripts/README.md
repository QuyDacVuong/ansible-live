# Deployment scripts

These scripts run from either an engineer's Macbook or GitHub Actions

In order to run locally, you need to have followed the setup guide in the main [README.md](../README.md)

## Usage

```shell
./stop_zone1.sh qa1
./start_zone1.sh qa1
```

### Environment variables

You can optionally set the following environment variables to control how the scripts run:

- `TRACE=1` to get debug output

### Alternative connection methods

SSM can be painfully slow with Ansible, particularly with Windows servers. SSM also depends on AWS DHMC working. It is possible to change the code to temporarily use winrm, but this is not recommended

1. Edit CONN_VARS to add `ansible_connection=psrp ansible_psrp_auth=ntlm ansible_psrp_cert_validation=ignore ansible_pipelining=true ansible_become=false ansible_user=csruser ansible_psrp_proxy=socks5://127.0.0.1:5986` (replacing `csruser` with your actual CSR username). This will configure Ansible to connect with PSRP over an SSH SOCKS proxy
2. Add `-k` to every call to `ansible`. This will repeatedly prompt you for your password to use with winrm
3. Remove `- instance-id` from `../aws_ec2.yml`. This will make the dynamic inventory plugin return IP addresses rather than instance IDs (which SSM uses) 
