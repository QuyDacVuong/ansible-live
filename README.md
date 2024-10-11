
# Ansible playbooks for GGN UKI

[![Actions Status](https://github.com/FlutterInt/fips-fst-ansible/actions/workflows/deploy-playbook.yml/badge.svg)](https://github.com/FlutterInt/fips-fst-ansible/actions/workflows/deploy-playbook.yml)

These playbooks are deployed from GitHub Actions in development, QA1 and Preprod environments

## Local setup

Local setup is optional, but can make things easier for initial creation of new playbooks in the development environment

### Option 1 - Docker

On your laptop:

1. Install and configure Docker however you see fit
2. Generate a Personal Access Token (PAT) from https://github.com/settings/tokens with read:packages  as the only required permission 
3. Copy the token string to your clipboard
4. `pbpaste | docker login ghcr.io -u $ --password-stdin`

You can now run the same version of Ansible that's used by GitHub Actions

```shell
docker run --rm -ti -v `pwd`:/runner -v ${HOME}/.aws:/runner/.aws -e AWS_REGION=eu-west-1 -e AWS_PROFILE=ggn-uki-development ghcr.io/flutterint/fips-casino-ansible-ee:latest ansible-inventory -i aws_ec2.yml --list
```

### Option 2 - native installs

If you are unable to use Docker or prefer local installations then you can follow the following instructions. However, note that you are responsible for keeping your installation maintained and inline with the container

1. run `brew install ansible` to install Ansible
2. ensure that `ansible --version` reports a core version of at least 2.15.0 from `/usr/local/bin/ansible`
3. copy `contrib/awsconfig` to `~/.aws/config`, changing the `sso_role_name` entries to ones you have access to (as listed in Okta)
4. run `aws sso login --profile ggn-uki-development` to login to the development environment
5. run `aws sts get-caller-identity --profile ggn-uki-development` to ensure you have access to AWS
6. Disable thread safety with `export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES`
7. Run `ansible-galaxy-3 collection install -c -r requirements.yml` on your laptop to locally checkout collection dependencies

## Linux/Windows deployment

Deployment from GitHub Actions is now the preferred method, using https://github.com/FlutterInt/fips-fst-ansible/actions/workflows/deploy-playbook.yml


However, you can still deploy from your local machine if required (Only to linux hosts)

Github Actions now uses 2 different types of anisble connections for deploying playbooks. Linux uses aws_ssm plugin whereas windows playbooks use psrp connection. The type of conneciton it uses is handled in the workflow based on the type of playbook you choose to deploy.


Prerequisites for running ansible using SSM.

1. The remote EC2 instance must be running the [AWS Systems Manager Agent (SSM Agent)](https://docs.aws.amazon.com/systems-manager/latest/userguide/ssm-agent.html)
2. The remote EC2 instance must have the curl installed. On Windows, curl should already be present as it's an alias for [Invoke-WebRequest](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest?view=powershell-6).
3. The control machine/laptop must have the [AWS Session Manager Plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html) installed.

Run `AWS_PROFILE=ggn-uki-development ansible-playbook cipwa.yml -i aws_ec2.yml -v -e "env=development"` to deploy CIPWA to the development environment


```shell
# Run all tasks on all Linux servers
AWS_PROFILE=ggn-uki-development ansible-playbook linux.yml -v -i aws_ec2.yml -e "env=development"

# Run all tasks only on group of servers
AWS_PROFILE=ggn-uki-development ansible-playbook cipwa.yml -v -i aws_ec2.yml -e "env=development"
```
# Self hosted Github runner workflow for GGN UKI

[![Actions Status](https://github.com/FlutterInt/fips-fst-ansible/actions/workflows/configure-runner.yml/badge.svg)](https://github.com/FlutterInt/fips-fst-ansible/actions/workflows/configure-runner.yml)

## Install runner as a service

This workflow action will perform following actions:

 - Create necessary directories, users, groups.
 - Install all dependency packages
 - Download the runner install and scripts for installation
 - Configure the runner instances based on specified number of instances.

Required variables :

 - Select the environment in which you want to configure the runner.
 - Select number of runners you want to configure on single host.
 - Input any additional labels you want to pass in for your runners.


## Uninstall running as service

This workflow action will perform following actions:

 - For n number of runners in given environment you have to run this workflow n number of times, unlike install action, you cannot uninstall all runners for a given environment in one execution. 
 - Stops and uninstalls the systemd (linux) service
 - Acquires a removal token
 - Uninstalls service for the specified runner

Required variables :

 - Select the environment in which you want to uninstall the runner.
 - Select which runner you want to uninstall ex (1,2,3)

### Delete an offline runner

Deletes a registered runner that is offline (Do not run before Uninstall):

 - Resolves id from name ( runner name is identified by input variable)
 - Deletes the runner

Inputs :

 - Select the environment in which you want to delete the runner.
 - Select which runner you want to uninstall ex (1,2,3)
 
## OS patching

OS patching is performed by updating the AMI to the latest from the relevant upstream teams (Linux/Windows). AMI update and rollout is under the control of the [terraform projec](https://github.com/Flutter-Global/terraform-stack-ggn-uki-infrastructure)
 
# Upgrades and other outage-requiring changes

Sometimes deployments require outages. Whether this is a configuration change, an application upgrade, or OS patching, we treat these all the same.

By default, the Ansible playbooks start/stop/restart services as required. You can skip this by passing in `--skip-tags launch -e "flag_no_restart=1"`. This requires the relevant tasks to have the corresponding tag:

```yaml
  tags:
    - launch
```

and tasks to have the following when:

```yaml
  when: flag_no_restart is not defined
```

The two separate ways of doing this are because handlers always run, regardless of tags.

A deployment involving more careful stopping and starting might look like:

```shell
./deployment-scripts/stop_zone1_linux.sh qa1 
AWS_REGION=eu-west-1 AWS_PROFILE=ggn-uki-development ansible-playbook linux.yml -v -i aws_ec2.yml -e "env=development flag_no_restart=1" --skip-tags=launch
./deployment-scripts/start_zone1_linux.sh qa1
AWS_REGION=eu-west-1 AWS_PROFILE=ggn-uki-development ansible-playbook linux.yml -v -i aws_ec2.yml -e "env=development flag_no_restart=1" --skip-tags=launch
```

See [deployment-scripts/README.md](deployment-scripts/README.md) for more details on deployment scripts and integration tests

# Code linting

You should lint your code before creating a PR, but this isn't currently enforced

```shell
# full run with auto-fix
docker run --rm -ti -v `pwd`:/src/playbook -w /src/playbook ghcr.io/ansible/creator-ee:latest ansible-lint  --write 

# quick run for basic checks with auto-fix
docker run --rm -ti -v `pwd`:/src/playbook -w /src/playbook ghcr.io/ansible/creator-ee:latest ansible-lint --offline --write
```
