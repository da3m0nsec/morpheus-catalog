# Jenkins Ansible Role

This role installs and configures Jenkins CI/CD server on Linux systems.

## Supported Operating Systems

- **Debian/Ubuntu**: Uses APT package manager
- **CentOS/Rocky/RHEL**: Uses YUM/DNF package manager

## Requirements

- Ansible 2.9 or higher
- Target hosts must have internet access to download Jenkins packages
- Root or sudo privileges on target hosts

## Role Variables

### Main Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `jenkins_version` | `latest` | Jenkins version to install |
| `jenkins_port` | `8080` | HTTP port for Jenkins web interface |
| `jenkins_home` | `/var/lib/jenkins` | Jenkins home directory |
| `jenkins_configure_firewall` | `false` | Whether to configure firewall rules |

### OS-Specific Variables

The role automatically detects the OS family and uses appropriate variables:

- **Java Package**: `jenkins_java_package_debian` or `jenkins_java_package_redhat`
- **Repository URLs**: Automatically selected based on OS family

### Additional Packages

```yaml
jenkins_additional_packages:
  - git
  - curl
```

## Dependencies

None.

## Example Playbook

```yaml
- hosts: jenkins_servers
  become: yes
  roles:
    - jenkins
```

## Example with Custom Variables

```yaml
- hosts: jenkins_servers
  become: yes
  vars:
    jenkins_port: 9090
    jenkins_additional_packages:
      - git
      - docker.io
  roles:
    - jenkins
```

## Post-Installation

After installation, Jenkins will be:
- Running on the configured port (default: 8080)
- Enabled to start on boot
- Accessible via web interface

To get the initial admin password:
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

## License

MIT

## Author Information

This role was created for the Morpheus Catalog project.

