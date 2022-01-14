storage "raft" {
  path    = "./vault/data"
  node_id = "node_1"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_cert_file = "/vault/config/vault-cert.pem"
  tls_key_file  = "/vault/config/vault-key.pem"
}

api_addr = "https://vault.docker.lol"
cluster_addr = "https://127.0.0.1:8201"
ui = true