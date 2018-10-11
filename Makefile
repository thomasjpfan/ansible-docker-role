.PHONY: gen_root_ca gen_server_certs gen_client_certs gen_all_certs

CERT_DIR:=molecule/default/certs
JSON_DIR:=molecule

gen_root_ca: $(CERT_DIR)/ca-key.pem

gen_server_certs: $(CERT_DIR)/server-key.pem

gen_client_certs: $(CERT_DIR)/client-key.pem

gen_all_certs: gen_root_ca gen_server_certs gen_client_certs

$(CERT_DIR)/ca-key.pem:
	cfssl gencert -initca $(JSON_DIR)/ca-csr.json | cfssljson -bare $(CERT_DIR)/ca -

$(CERT_DIR)/server-key.pem: $(CERT_DIR)/ca-key.pem
	cfssl gencert -ca=$(CERT_DIR)/ca.pem -ca-key=$(CERT_DIR)/ca-key.pem \
	-config=$(JSON_DIR)/ca-config.json -profile=server $(JSON_DIR)/server.json | \
	cfssljson -bare $(CERT_DIR)/server

$(CERT_DIR)/client-key.pem: $(CERT_DIR)/ca-key.pem
	cfssl gencert -ca=$(CERT_DIR)/ca.pem -ca-key=$(CERT_DIR)/ca-key.pem \
	-config=$(JSON_DIR)/ca-config.json -profile=client $(JSON_DIR)/client.json | \
	cfssljson -bare $(CERT_DIR)/client
