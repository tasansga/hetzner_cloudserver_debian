resource "random_string" "test" {
  length  = 10
  upper   = false
  special = false
}

locals {
  name = "test${random_string.test.result}"
}

provider "hcloud" {
  token   = var.hcloud_token
  version = "~> 1.16"
}

resource "hcloud_network" "internal" {
  name     = "${local.name}-network"
  ip_range = "10.0.0.0/8"
}

resource "hcloud_network_subnet" "subnet" {
  network_id   = hcloud_network.internal.id
  type         = "server"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

resource "tls_private_key" "internal" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

resource "hcloud_ssh_key" "internal" {
  name       = local.name
  public_key = tls_private_key.internal.public_key_openssh
}

module "cloudserver" {
  source              = "../"
  name                = local.name
  hcloud_token        = var.hcloud_token
  server_type         = "cx11"
  server_number       = 1
  network_id          = hcloud_network.internal.id
  ssh_private_key     = tls_private_key.internal.private_key_pem
  ssh_public_key      = tls_private_key.internal.public_key_openssh
  username            = local.name
  ssh_key_names       = [local.name]
  ssh_authorized_keys = [tls_private_key.internal.public_key_openssh]
}
