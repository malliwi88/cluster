#!/bin/bash

cp ../_setup/* .
CLUSTER_SIZE=4 vagrant up
vagrant ssh-config core-01 | sed -n "s/IdentityFile//gp" | xargs ssh-add
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
export FLEETCTL_TUNNEL="$(vagrant ssh-config core-01 | sed -n "s/[ ]*HostName[ ]*//gp"):$(vagrant ssh-config | sed -n "s/[ ]*Port[ ]*//gp")"
export KUBERNETES_MASTER=$(vagrant ssh core-01 -c "ip -f inet -o addr show eth1 | cut -d\  -f 7 | cut -d/ -f 1 | tr -d '[[:space:]]'")

cd ../_fleet-services
ln -s templates/kube-proxy@.service kube-proxy@${KUBERNETES_MASTER}.service
ln -s templates/kube-kubelet@.service kube-kubelet@${KUBERNETES_MASTER}.service

cd ../kubernetes-multiple-nodes
fleetctl load ../_fleet-services/*.service
fleetctl start ../_fleet-services/*.service

# Cleanup
rm ../_fleet-services/kube-proxy@${KUBERNETES_MASTER}.service
rm ../_fleet-services/kube-kubelet@${KUBERNETES_MASTER}.service

fleetctl list-units