# Ansible Playbooks and Roles

This directory contains Ansible playbooks, roles, and configuration for automating infrastructure deployments in the Morpheus Catalog project.

## Directory Structure

```
ansible/
├── playbooks/          # Ansible playbooks
│   └── install-jenkins.yml
├── roles/              # Reusable Ansible roles
│   └── jenkins/
│       ├── tasks/
│       ├── handlers/
│       ├── defaults/
│       └── README.md
├── group_vars/         # Group-specific variables
│   └── all.yml
├── host_vars/          # Host-specific variables
├── inventory/          # Inventory files
│   └── hosts.example
├── ansible.cfg         # Ansible configuration
└── README.md           # This file
```

## Prerequisites

- **Ansible**: Version 2.9 or higher
- **Python**: Python 2.7+ or Python 3.5+ on target hosts
- **SSH Access**: SSH access to target hosts with sudo privileges
- **Network**: Target hosts must have internet access to download packages

### Installing Ansible

**On Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install ansible
```

**On CentOS/Rocky/RHEL:**
```bash
sudo yum install epel-release
sudo yum install ansible
# or with DNF
sudo dnf install ansible
```

**Using pip:**
```bash
pip install ansible
```

## Quick Start

### 1. Set Up Inventory

Copy the example inventory file and customize it with your hosts:

```bash
cp inventory/hosts.example inventory/hosts
```

Edit `inventory/hosts` with your actual host information:

```ini
[jenkins_servers]
jenkins1 ansible_host=192.168.1.10 ansible_user=ubuntu
jenkins2 ansible_host=192.168.1.11 ansible_user=centos
```

### 2. Test Connection

Verify you can connect to your hosts:

```bash
ansible all -i inventory/hosts -m ping
```

### 3. Run a Playbook

Install Jenkins on all hosts in the `jenkins_servers` group:

```bash
ansible-playbook -i inventory/hosts playbooks/install-jenkins.yml
```

Install Jenkins on specific hosts:

```bash
ansible-playbook -i inventory/hosts playbooks/install-jenkins.yml --limit jenkins1
```

## Available Playbooks

### install-jenkins.yml

Installs and configures Jenkins CI/CD server on target hosts.

**Supported Operating Systems:**
- Ubuntu/Debian
- CentOS/Rocky/RHEL

**Usage:**
```bash
ansible-playbook -i inventory/hosts playbooks/install-jenkins.yml
```

**Custom Variables:**
```bash
ansible-playbook -i inventory/hosts playbooks/install-jenkins.yml \
  -e "jenkins_port=9090"
```

## Roles

### jenkins

A reusable role for installing Jenkins on Linux systems.

**Features:**
- Multi-OS support (Debian/Ubuntu and CentOS/Rocky/RHEL)
- Automatic OS detection
- Idempotent installation
- Service management
- Post-installation verification

See `roles/jenkins/README.md` for detailed documentation.

## Variables

### Group Variables

Group variables are defined in `group_vars/all.yml` and apply to all hosts. You can also create OS-specific group variables:

- `group_vars/debian.yml` - For Debian/Ubuntu hosts
- `group_vars/redhat.yml` - For CentOS/Rocky/RHEL hosts

### Host Variables

Host-specific variables can be defined in `host_vars/<hostname>.yml`.

### Overriding Variables

Variables can be overridden at runtime:

```bash
ansible-playbook -i inventory/hosts playbooks/install-jenkins.yml \
  -e "jenkins_port=9090 jenkins_version=2.414.1"
```

## Inventory Management

### Static Inventory

Use the `inventory/hosts` file for static inventory management. See `inventory/hosts.example` for format.

### Dynamic Inventory

Ansible supports dynamic inventory from cloud providers, CMDB systems, etc. Configure in `ansible.cfg` or use inventory plugins.

## Best Practices

1. **Use Roles**: Encapsulate reusable functionality in roles
2. **Idempotency**: Ensure playbooks can be run multiple times safely
3. **Variables**: Use variables for configuration, not hardcoded values
4. **Secrets**: Use Ansible Vault for sensitive data
5. **Testing**: Test playbooks in a development environment first
6. **Documentation**: Document roles and playbooks with README files

## Ansible Vault

For sensitive data like passwords or API keys, use Ansible Vault:

**Create encrypted file:**
```bash
ansible-vault create group_vars/secrets.yml
```

**Edit encrypted file:**
```bash
ansible-vault edit group_vars/secrets.yml
```

**Run playbook with vault:**
```bash
ansible-playbook -i inventory/hosts playbooks/install-jenkins.yml --ask-vault-pass
```

## Troubleshooting

### Connection Issues

- Verify SSH connectivity: `ssh user@hostname`
- Check SSH key permissions: `chmod 600 ~/.ssh/id_rsa`
- Test with verbose output: `ansible-playbook -vvv ...`

### Permission Issues

- Ensure user has sudo privileges
- Use `--become` flag or set `become: yes` in playbook
- Check sudoers configuration on target hosts

### Package Installation Issues

- Verify internet connectivity on target hosts
- Check repository configuration
- Review package manager logs on target hosts

## Examples

### Install Jenkins on Specific OS

**Ubuntu/Debian only:**
```bash
ansible-playbook -i inventory/hosts playbooks/install-jenkins.yml \
  --limit "jenkins_servers:&debian"
```

**CentOS/Rocky only:**
```bash
ansible-playbook -i inventory/hosts playbooks/install-jenkins.yml \
  --limit "jenkins_servers:&redhat"
```

### Dry Run (Check Mode)

Test what would change without making changes:

```bash
ansible-playbook -i inventory/hosts playbooks/install-jenkins.yml --check
```

### Verbose Output

Get detailed output for debugging:

```bash
ansible-playbook -i inventory/hosts playbooks/install-jenkins.yml -vvv
```

## Integration with Morpheus

These Ansible playbooks can be integrated with Morpheus:

1. **Automation Tasks**: Create automation tasks that run these playbooks
2. **Workflows**: Include playbook execution in provisioning workflows
3. **Instance Types**: Use playbooks for post-provisioning configuration
4. **Service Catalog**: Expose playbooks as catalog items

## Additional Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)

## License

MIT

## Contributing

When adding new playbooks or roles:

1. Follow the existing directory structure
2. Include README.md files for roles
3. Use variables for configuration
4. Ensure idempotency
5. Test on multiple OS distributions
6. Document usage and examples

