Table of Contents:
1. [Architecture Overview] (#architecture-overview)
2. [Prerequisites](#prerequisites)
3. [Part 1: Terraform Backend Setup] (part-1-terraform-backend-setup)
4. [Part 2: GitHub OIDC Identity Provider] (part-2-github-oidc-identity-provider)
5. [Part 3: Infrastructure Deployment] (part-3-infrastructure-deployment)
6. [Part 4: Ansible Configuration] (part-4-ansible-configuration)
7. [Part 5: Windows Server Access] (part-5-windows-server-access)
8. [Troubleshooting Guide] (troubleshooting-guide)
--------------------------------------
Prerequisites 
10. Architecture Overview
Infrastructure Components
- 1 Ansible Control Node (Ubuntu Linux EC2)
- 1 Linux Target Server (Ubuntu Linux EC2)
- 1 Windows Target Server (Windows Server 2022 EC2)
- S3 Backend for Terraform state storage
- DynamoDB Table for state locking
- GitHub OIDC Provider for secure CI/CD
Network Architecture
- VPC with public subnet (10.0.0.0/16)
- Internet Gateway for public access
- Security groups for each server type
- Private IP communication between Ansible and targets
Deployment Flow
Developer → GitHub Actions → AWS (OIDC) → Terraform → EC2 Instances → Ansible →
Nginx Deployment
Prerequisites
Required Tools
- AWS CLI configured with credentials
- Terraform (v1.6+)
- Git and GitHub account
- SSH key pair created in AWS
- Text editor (VS Code recommended)
Required Information
- AWS Account ID
- GitHub username/organization
- Your public IP address
- EC2 key pair name
Getting Your Public IP
```bash
curl ifconfig.me
```
------------------------------------------------------------------------------------------------
Part 1: Terraform Backend Setup

Step 1.1: Create Backend Infrastructureand deploy in the main Terraform 

https://github.com/Arnauld-20/ansible_repo/blob/main/terraform/providers.tf
---------

---------------------------------------------------------
Part 2: GitHub Access keys Identity Provider
From AWS - get the keys pairs and download the .pem files 
-----------
Step 2.2: Configure GitHub Secrets
1. Go to repository: Settings → Secrets and variables → Actions
2. Add secret:
- Name: `AWS_ROLE_ARN`
- Value: `arn:aws:iam::123456789012:role/GitHubActionsRole`

Step 2.3: GitHub Actions Workflow
File: `.github/workflows/terraform.yml`
------------------------
name: Terraform Deploy
on:
push:
branches: [main]
permissions:
id-token: write
contents: read
jobs:
terraform:
runs-on: ubuntu-latest
steps:
- uses: actions/checkout@v4
- name: Configure AWS Credentials
uses: aws-actions/configure-aws-credentials@v4
with:
role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
aws-region: us-east-1
- name: Setup Terraform
uses: hashicorp/setup-terraform@v3
- name: Terraform Apply
run: |
terraform init

-----------------------
Part 3: Infrastructure Deployment
Step 3.1: Create Variables File
File: `terraform.tfvars`
-------------------
aws_region = "us-east-1"
key_name = "your-key-pair-name"
my_ip = "203.0.113.45/32" # YOUR public IP with /32
--------------------
Step 3.2: Deploy Infrastructure
```bash
------------------
terraform init
terraform plan

----------------
Step 3.3: Record Outputs
After deployment, save these values:
- Ansible control node public IP
- Linux target private IP
- Windows target private IP
- Windows target public IP
---------------------------------------------------------------
Part 4: Ansible Configuration
Step 4.1: SSH into Ansible Control Node
```bash
ssh -i your-key.pem ubuntu@ANSIBLE_CONTROL_IP
```
Step 4.2: Copy SSH Key to Control Node
```bash
# From your local machine
scp -i your-key.pem your-key.pem ubuntu@ANSIBLE_CONTROL_IP:~/.ssh/id_rsa
ssh ubuntu@ANSIBLE_CONTROL_IP "chmod 600 ~/.ssh/id_rsa"
```
Step 4.3: Create Ansible Inventory
File: `~/inventory.ini`
```yaml
download the inventory files https://github.com/Arnauld-20/ansible_repo/blob/main/ansible_deployments/inventory.ini
```
Step 4.4: Create Nginx Deployment Playbook
File: `~/deploy_nginx.yml`
```yaml
https://github.com/Arnauld-20/ansible_repo/blob/main/ansible_deployments/deploy_nginx.yml

Step 4.5: Test Connectivity
```bash
ansible linux_servers -m ping -i ~/inventory.ini
ansible windows_servers -m win_ping -i ~/inventory.ini
```
Step 4.6: Deploy Nginx
```bash
ansible-playbook -i ~/inventory.ini deploy_nginx.yml
```
Step 4.7: Verify Deployment
```bash
curl http://LINUX_PUBLIC_IP
curl http://WINDOWS_PUBLIC_IP
```
-------------------------------------------------------
Part 5: Windows Server Access
Required Port: 3389 (RDP)
Already configured in Terraform security group for your IP.
Step 5.1: Get Windows Password
Method 1: AWS Console
1. EC2 Console → Select Windows instance
2. Actions→ Security → Get Windows Password
3. Upload your `. pem` key file
4. Click **Decrypt Password**
5. Copy the password
Method 2: AWS CLI
```bash
aws ec2 get-password-data \
--instance-id i-xxxxx \
--priv-launch-key ~/.ssh/your-key.pem \
--query 'PasswordData' \
--output text | base64 -d | openssl rsautl -decrypt -inkey ~/.ssh/your-key.pem
```
Step 5.2: Connect via RDP
Windows
1. Press `Win + R`
2. Type `mstsc`
3. Enter Windows server public IP
4. Username: `Administrator`
5. Password: (from Step 5.1)
macOS:
1. Download Microsoft Remote Desktop from App Store
2. Add PC with public IP
3. Username: `Administrator`
4. Password: (from Step 5.1)
xfreerdp /u:Administrator /p:'PASSWORD' /v:PUBLIC_IP /size:1920x1080
Linux:
```bash
```
Step 5.3: Test Port Connectivity
```bash
nc -zv WINDOWS_PUBLIC_IP 3389
```
troubleshooting of windows:
----------------------------------------------updatedddd----
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

**--------------
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

Alternatively use this command to install:
dism /Online /Add-Capability /CapabilityName:OpenSSH.Server~~~~0.0.1.0
**------------

Start-Service sshd

Set-Service -Name sshd -StartupType 'Automatic'

if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
}

