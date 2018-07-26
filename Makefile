.PHONY: setup_test setup_local_test clean_up cli test cycle

CONTAINER_NAME?=ansible-local-runner
TEST_CONTAINER_TAG?=1.1.0-18.04-py3

setup_test:
	docker run --rm --privileged -d --name $(CONTAINER_NAME) \
	-v $(PWD):/etc/ansible/roles/role_to_test \
	-v /sys/fs/cgroup:/sys/fs/cgroup:ro  \
	-h $(CONTAINER_NAME) \
	thomasjpfan/ansible-ubuntu-local-runner:$(TEST_CONTAINER_TAG)

setup_local_test:
	docker run --rm --privileged -d --name $(CONTAINER_NAME) \
	-v $(PWD):/etc/ansible/roles/role_to_test \
	-v /sys/fs/cgroup:/sys/fs/cgroup:ro  \
	-e ANSIBLE_PLAYBOOK_ARGS="-e docker_use_local_cache=true" \
	--network ng \
	-h $(CONTAINER_NAME) \
	thomasjpfan/ansible-ubuntu-local-runner:$(TEST_CONTAINER_TAG)

cli:
	docker exec -ti $(CONTAINER_NAME) /bin/bash

test:
	docker exec -ti $(CONTAINER_NAME) cli all

cycle: setup_local_test test clean_up

clean_up:
	docker stop $(CONTAINER_NAME)


.PHONY: gen_root_ca gen_server_certs gen_client_certs gen_all_certs

CERT_DIR:=tests/certs

gen_root_ca: $(CERT_DIR)/ca-key.pem

gen_server_certs: $(CERT_DIR)/server-key.pem

gen_client_certs: $(CERT_DIR)/client-key.pem

gen_all_certs: gen_root_ca gen_server_certs gen_client_certs

$(CERT_DIR)/ca-key.pem:
	cfssl gencert -initca tests/ca-csr.json | cfssljson -bare $(CERT_DIR)/ca -

$(CERT_DIR)/server-key.pem: $(CERT_DIR)/ca-key.pem
	cfssl gencert -ca=$(CERT_DIR)/ca.pem -ca-key=$(CERT_DIR)/ca-key.pem \
	-config=tests/ca-config.json -profile=server tests/server.json | \
	cfssljson -bare tests/certs/server

$(CERT_DIR)/client-key.pem: $(CERT_DIR)/ca-key.pem
	cfssl gencert -ca=$(CERT_DIR)/ca.pem -ca-key=$(CERT_DIR)/ca-key.pem \
	-config=tests/ca-config.json -profile=client tests/client.json | \
	cfssljson -bare tests/certs/client
