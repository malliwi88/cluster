#!/bin/sh
### Base OS: Linux
### Distribution: Ubuntu 14.04.3 LTS - Trusty Tahr
### Kernel: 3.13.0-71-generic
###
### Starting on 14.04.3 perform a release upgrade and restart the node as 16.04
### do-release-upgrade -d

### Base update
apt-get update
apt-get upgrade -y

# Docker 1.8.3
apt-key adv \
--keyserver hkp://p80.pool.sks-keyservers.net:80 \
--recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-engine=1.8.3-0~trusty

# etcd 2.2.2
wget "https://github.com/coreos/etcd/releases/download/v2.2.2/etcd-v2.2.2-linux-amd64.tar.gz"
tar -xvzf etcd-v2.2.2-linux-amd64.tar.gz
mv etcd-v2.2.2-linux-amd64/etcd* /usr/local/bin/.
rm etcd-v2.2.2-linux-amd64.tar.gz
rm -rf etcd-v2.2.2-linux-amd64

# fleet 0.11.5
wget "https://github.com/coreos/fleet/releases/download/v0.11.5/fleet-v0.11.5-linux-amd64.tar.gz"
tar -xvzf fleet-v0.11.5-linux-amd64.tar.gz
mv fleet-v0.11.5-linux-amd64/fleet* /usr/local/bin/.
rm fleet-v0.11.5-linux-amd64.tar.gz
rm -rf fleet-v0.11.5-linux-amd64

# flannel 0.5.5
wget "https://github.com/coreos/flannel/releases/download/v0.5.5/flannel-0.5.5-linux-amd64.tar.gz"
tar -xvzf flannel-0.5.5-linux-amd64.tar.gz
mv flannel-0.5.5/flanneld /usr/local/bin/.
mv flannel-0.5.5/mk-docker-opts.sh /usr/local/bin/.
rm flannel-0.5.5-linux-amd64.tar.gz
rm -rf flannel-0.5.5

### CONFIGURATION
# memory and swap
sed -i 's/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"cgroup_enable=memory swapaccount=1\"/g' /etc/default/grub
update-grub

# firewall
sed -i 's/DEFAULT_FORWARD_POLICY=\"DROP\"/DEFAULT_FORWARD_POLICY=\"ACCEPT\"/g' /etc/default/ufw
ufw allow 2375/tcp

# DNS
sed -i 's/#DOCKER_OPTS=/DOCKER_OPTS=/g' /etc/default/docker

### SYSTEM SERVICES
# Install proper unit files to: /lib/systemd/system/
# systemctl daemon-reload
# systemctl start etcd2
# systemctl start fleet
# systemctl start flanneld
# systemctl start docker

# Base cluster services should start on boot
# systemctl enable etcd2
# systemctl enable fleet
# systemctl enable flanneld
# systemctl enable docker
