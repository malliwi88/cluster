#!/bin/bash

cp ../_setup/* .
CLUSTER_SIZE=1 vagrant up
vagrant ssh-config core-01 | sed -n "s/IdentityFile//gp" | xargs ssh-add
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
export FLEETCTL_TUNNEL="$(vagrant ssh-config core-01 | sed -n "s/[ ]*HostName[ ]*//gp"):$(vagrant ssh-config | sed -n "s/[ ]*Port[ ]*//gp")"
export KUBERNETES_MASTER=$(vagrant ssh core-01 -c "ip -f inet -o addr show eth1 | cut -d\  -f 7 | cut -d/ -f 1 | tr -d '[[:space:]]'")

cd ../_fleet-services
ln -s templates/kube-proxy@.service kube-proxy@127.0.0.1.service
ln -s templates/kube-kubelet@.service kube-kubelet@127.0.0.1.service

cd ../kubernetes-single-node
fleetctl load ../_fleet-services/*.service
fleetctl start ../_fleet-services/*.service
rm ../_fleet-services/kube-proxy@127.0.0.1.service
rm ../_fleet-services/kube-kubelet@127.0.0.1.service
fleetctl list-units

echo "Done"
echo "Inspect the cluster when all units al running: "
echo "kubectl -s ${KUBERNETES_MASTER}:8080 cluster-info"
echo "kubectl -s ${KUBERNETES_MASTER}:8080 get nodes"