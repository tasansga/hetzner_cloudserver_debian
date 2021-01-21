#!/bin/bash
#shellcheck disable=SC2154,SC2016

set -euo pipefail

IFS=$'\n\t'
export DEBIAN_FRONTEND=noninteractive

cat << EOF > /etc/apt/apt.conf.d/90_always_yes
APT::Get::Assume-Yes "true";
EOF

apt-get update -yq

apt-get install -yq \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

groupadd docker

echo "${username}"
useradd -md "/home/${username}" -s /bin/bash -G docker "${username}"
su "${username}" <<EOF
set -e
mkdir -p /home/${username}/.ssh
chmod 0700 /home/${username}/.ssh
%{ for key in authorized_keys ~}
echo "${key}" >> /home/${username}/.ssh/authorized_keys
%{ endfor ~}
chmod 644 /home/${username}/.ssh/authorized_keys
cp -v /tmp/id_rsa /tmp/id_rsa.pub /home/${username}/.ssh
chmod 600 /home/${username}/.ssh/id_rsa*
EOF

rm -vf /tmp/id_rsa /tmp/id_rsa.pub

echo '${username} ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

usermod -aG docker "${username}"

curl \
    --silent \
    --show-error \
    --location \
    --retry 5 \
    --fail \
    https://download.docker.com/linux/debian/gpg | apt-key add -

apt-key fingerprint 0EBFCD88

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

apt-get update

apt-get install -yq \
    docker-ce \
    docker-ce-cli \
    containerd.io

systemctl enable docker.service
systemctl start docker.service

cat << EOF > /etc/ssh/sshd_config
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
SyslogFacility AUTHPRIV
PermitRootLogin no
MaxAuthTries 5
AuthorizedKeysFile .ssh/authorized_keys
PasswordAuthentication no
ChallengeResponseAuthentication no
GSSAPIAuthentication no
GSSAPICleanupCredentials no
UsePAM yes
X11Forwarding no
ClientAliveInterval 20
AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
AcceptEnv LC_IDENTIFICATION LC_ALL LANGUAGE
AcceptEnv XMODIFIERS
Subsystem sftp /usr/libexec/openssh/sftp-server
AllowUsers ${username}
EOF

(sleep 0.2 && systemctl restart ssh.service)
