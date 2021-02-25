variable "hcloud_token" {
  type = string
}

variable "name" {
  description = "Server cluster name"
  type        = string
}

variable "server_type" {
  description = "Hetzner Cloud Server type"
  type        = string
  default     = "cx11"
}

variable "server_number" {
  description = "Number of servers to create"
  type        = number
  default     = 2
}

variable "network_id" {
  description = "Network id for the hcloud_server_network"
  type        = string
}

variable "ssh_key_names" {
  description = "List of Hetzner identifiers for SSH keys"
  type        = list(string)
}

variable "username" {
  description = "User name to create on the server for SSH logins"
  type        = string
}

variable "ssh_private_key" {
  description = "Private SSH key to connect to the server"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "Public SSH key for the server's user"
  type        = string
}

variable "ssh_authorized_keys" {
  description = "List of SSH public keys to add to authorized_keys"
  type        = list(string)
  default     = []
}
