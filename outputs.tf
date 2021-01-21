
output "internal_ipv4_address" {
  value = hcloud_server_network.internal[*].ip
}

output "external_ipv4_address" {
  value = hcloud_server.server[*].ipv4_address
}

