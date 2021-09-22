# CLOUD APPLICATION SETUP USING TERRAFORM AND ANSIBLE

## Setup
1. Create an IAM role for Terraform and Ansible instance to access the 2nd EC2 instance with server setup - EC2FullAccess
2. Attach above IAM role to Devops EC2 instance
3. [Install terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
4. Go into devops instance and generate keys - `ssh-keygen -t rsa -f ~./.ssh/openvpn-key`
5. `chmod 600 ~/.ssh/openvpn-key`
6. Make changes as needed for ./vars.json

## Setup infrastructure
Run the following commands to setup the server for openvpn service

```
cd terraform
terraform init
terraform plan --var-file ../vars.json
terraform apply --var-file ../vars.json
```

## Setup VPN
```
cd ansible
 ansible-playbook --private-key=~/.ssh/openvpn-key --become --user=ec2-user --inventory-file
=inventory openvpn_setup_playbook.yml
```