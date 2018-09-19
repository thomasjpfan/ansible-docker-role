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

This project uses [ansible-ubuntu-local-runner)](https://github.com/thomasjpfan/ansible-ubuntu-local-runner) to run tests in a docker container.

1. Start Container for testing:

```bash
make setup_test
```

2. Run Tests

```bash
make test
```

3. Stop up container

```bash
make clean_up
```

## Local Testing

The `tests/playbook.yml` file includes a pre-tasks that adds a ubuntu cacher configuration for local testing. You can start your own cacher by running:

```bash
docker run --name apt-cacher -d --restart=always \
  --publish 3142:3142 \
  --volume /srv/docker/apt-cacher-ng:/var/cache/apt-cacher-ng \
  --network ng \
  sameersbn/apt-cacher-ng:latest
```

To use to cache for local testing run `make setup_local_test` instead of `make setup_test`.

## License

MIT
