# Ansible Docker Role

[![Build Status](https://travis-ci.org/thomasjpfan/ansible-docker-role.svg?branch=master)](https://travis-ci.org/thomasjpfan/ansible-docker-role)

Installs Docker-CE on an Ubuntu 16.04 and setting up TLS certificates.

## Role Variables

```yaml
# Docker channel and version to install
docker_channel: stable
docker_version: 18.06.1~ce~3-0~ubuntu

# Paths of certs to interact with the docker api
? docker_local_cacert
? docker_local_tlscert
? docker_local_tlskey

# Path on host to place ssl
docker_server_cert_path: /etc/docker/ssl

# configure daemon.json for dockerd
? docker_daemon_json

# List of users to be added to 'docker' system group
docker_group_members: []
```

## Testing

This project uses [molecule](https://molecule.readthedocs.io) for testing:

```bash
pip install -r requirements.txt
molecule test
```

## License

MIT
