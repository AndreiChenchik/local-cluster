storage "raft" {
  path    = "./vault/data"
  node_id = "node_1"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"
}

api_addr = "https://vault.casa.chenchik.me"
cluster_addr = "https://127.0.0.1:8201"
ui = true