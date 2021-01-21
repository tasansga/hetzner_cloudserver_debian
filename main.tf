resource "hcloud_server" "server" {
  count       = var.server_number
  name        = format("${var.name}-%0.2d", count.index + 1)
  server_type = var.server_type
  location    = "hel1"
  image       = "debian-10"
  ssh_keys    = var.ssh_key_names

  connection {
    type        = "ssh"
    user        = "root"
    private_key = var.ssh_private_key
    host        = self.ipv4_address
  }

  provisioner "file" {
    destination = "/tmp/provision.sh"
    content = templatefile(
      "${path.module}/provision.sh",
      {
        username        = var.username,
        authorized_keys = var.ssh_authorized_keys
      }
    )
  }

  provisioner "file" {
    destination = "/tmp/id_rsa"
    content     = var.ssh_private_key
  }

  provisioner "file" {
    destination = "/tmp/id_rsa.pub"
    content     = var.ssh_public_key
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "chmod +x /tmp/provision.sh",
      "/tmp/provision.sh",
      "rm -vf /tmp/provision.sh"
    ]
  }
}

resource "hcloud_server_network" "internal" {
  count      = var.server_number
  server_id  = hcloud_server.server[count.index].id
  network_id = var.network_id

  connection {
    type        = "ssh"
    user        = var.username
    private_key = var.ssh_private_key
    host        = hcloud_server.server[count.index].ipv4_address
  }

  provisioner "file" {
    destination = "/tmp/network-internal.sh"
    content = templatefile(
      "${path.module}/network-internal.sh",
      {
        internal_ipv4_address = self.ip
      }
    )
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "chmod +x /tmp/network-internal.sh",
      "/tmp/network-internal.sh",
      "rm -vf /tmp/network-internal.sh"
    ]
  }
}
