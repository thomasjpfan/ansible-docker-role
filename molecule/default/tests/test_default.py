import os
import json

ssl_path = "/etc/docker/ssl"
cert_path = os.path.join(ssl_path, "server-cert.pem")
key_path = os.path.join(ssl_path, "server-key.pem")
ca_path = os.path.join(ssl_path, "ca.pem")
client_cert_path = os.path.join(ssl_path, "client-cert.pem")
client_key_path = os.path.join(ssl_path, "client-key.pem")


def test_docker_installed(host):
    assert host.service("docker").is_enabled
    assert host.service("docker").is_running


def test_user_in_group(host):
    d_groups = host.user("deploy").groups
    assert "docker" in d_groups


# check certs are there
def test_certs_installed(host):
    cert_dir = host.file(ssl_path)

    assert cert_dir.is_directory
    assert cert_dir.mode == 0o0444

    cert = host.file(cert_path)
    key = host.file(key_path)
    ca = host.file(ca_path)

    with host.sudo():
        assert cert.exists
        assert key.exists
        assert ca.exists
        assert cert.mode == 0o0444
        assert key.mode == 0o400
        assert ca.mode == 0o444


def test_daemon_json(host):
    daemon_json = host.file("/etc/docker/daemon.json")
    assert daemon_json.is_file
    assert daemon_json.mode == 0o0644

    daemon = json.loads(daemon_json.content_string)
    assert daemon["tlsverify"]

    assert "tcp://ansible-local:2376" in daemon["hosts"]
    assert cert_path == daemon["tlscert"]
    assert key_path == daemon["tlskey"]
    assert ca_path == daemon["tlscacert"]
    assert "8.8.8.8" in daemon["dns"]
    assert "8.8.4.4" in daemon["dns"]
    assert not daemon["ipv6"]
    assert daemon["log-driver"] == "json-file"
    assert daemon["log-opts"]["max-size"] == "10m"
    assert daemon["log-opts"]["max-file"] == "1000"


def test_systemd_override(host):
    override_path = "/etc/systemd/system/docker.service.d"
    override_dir = host.file(override_path)

    assert override_dir.is_directory
    assert override_dir.mode == 0o0755

    override_file_path = os.path.join(override_path, "override.conf")
    override_path = host.file(override_file_path)

    assert override_path.is_file
    assert override_path.mode == 0o0644


def test_docker_tls_verify(host):
    cmd_s = ("docker --tlsverify --tlscacert=%s --tlscert=%s "
             "--tlskey=%s -H=ansible-local:2376 version")
    cmd = host.run(cmd_s, ca_path, client_cert_path, client_key_path)
    assert cmd.rc == 0


def test_docker_crontab(host):
    cmd = host.run("crontab -l")
    assert cmd.rc == 0
    assert "docker system prune -af" in cmd.stdout
