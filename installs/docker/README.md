# Docker Installation and Configuration

This directory contains scripts and documentation for installing and configuring Docker.

## Contents

- `install_docker.sh` - Installation script for Docker Engine

## Installation

Run the installation script:

```bash
bash install_docker.sh
```

## Requirements

- Linux-based operating system
- Root or sudo privileges
- 64-bit architecture

## Features

- Automated installation of Docker Engine
- Docker Compose installation
- Service management
- User group configuration

## Usage

After installation, Docker will be available as a system service:

```bash
# Start Docker
sudo systemctl start docker

# Stop Docker
sudo systemctl stop docker

# Check status
sudo systemctl status docker

# Enable on boot
sudo systemctl enable docker
```

## Basic Docker Commands

```bash
# Check Docker version
docker --version

# Run a test container
docker run hello-world

# List running containers
docker ps

# List all containers
docker ps -a

# List images
docker images

# Pull an image
docker pull ubuntu:latest

# Run a container
docker run -it ubuntu:latest /bin/bash
```

## Docker Compose

Docker Compose is included in the installation for managing multi-container applications:

```bash
# Check Docker Compose version
docker-compose --version

# Start services defined in docker-compose.yml
docker-compose up

# Start services in background
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs
```

## User Permissions

The installation script adds the current user to the `docker` group, allowing Docker commands without `sudo`. You may need to log out and back in for this to take effect.

```bash
# To manually add a user to docker group
sudo usermod -aG docker $USER
```

## Configuration

Docker configuration files:
- `/etc/docker/daemon.json` - Docker daemon configuration
- `/var/lib/docker/` - Docker data directory
- `~/.docker/config.json` - User-specific Docker configuration

## Security Notes

- Only add trusted users to the docker group
- Keep Docker updated
- Use official images when possible
- Scan images for vulnerabilities
- Don't run containers as root unless necessary
- Use Docker secrets for sensitive data
- Configure resource limits

## Useful Resources

- Docker Documentation: https://docs.docker.com/
- Docker Hub: https://hub.docker.com/
- Docker Compose Documentation: https://docs.docker.com/compose/
