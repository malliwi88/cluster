#!/bin/bash
CLUSTER_SIZE=1 vagrant up
vagrant ssh-config core-01 | sed -n "s/IdentityFile//gp" | xargs ssh-add
export CLUSTER_MASTER=$(vagrant ssh core-01 -c "ip -f inet -o addr show eth1 | cut -d\  -f 7 | cut -d/ -f 1 | tr -d '[[:space:]]'")
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
# On Yosemite 10.10.4 ssh tunneling is not working any more
# export FLEETCTL_TUNNEL="$(vagrant ssh-config core-01 | sed -n "s/[ ]*HostName[ ]*//gp"):$(vagrant ssh-config | sed -n "s/[ ]*Port[ ]*//gp")"

fleetctl --endpoint=http://${CLUSTER_MASTER}:4001 load services/*.service
fleetctl --endpoint=http://${CLUSTER_MASTER}:4001 start services/*.service
fleetctl --endpoint=http://${CLUSTER_MASTER}:4001 list-units

echo ""
echo "Inspect the cluster when all units are running: "
echo "kubectl -s ${CLUSTER_MASTER}:8080 cluster-info"
echo "kubectl -s ${CLUSTER_MASTER}:8080 get nodes"