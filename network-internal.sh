#!/bin/bash
#shellcheck disable=SC2154,SC2016

set -euo pipefail

IFS=$'\n\t'

sudo bash -c "cat > /etc/network/interfaces.d/60-internal-network.cfg" << EOF
auto ens10:1
iface ens10:1 inet static
   address ${internal_ipv4_address}
   netmask 32
EOF

(sleep 0.2 ; sudo systemctl restart networking || true)
