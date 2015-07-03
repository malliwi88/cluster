#!/bin/bash
CLUSTER_SIZE=1 vagrant up
vagrant ssh-config core-01 | sed -n "s/IdentityFile//gp" | xargs ssh-add
export CLUSTER_MASTER=$(vagrant ssh core-01 -c "ip -f inet -o addr show eth1 | cut -d\  -f 7 | cut -d/ -f 1 | tr -d '[[:space:]]'")
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
# On Yosemite 10.10.4 ssh tunneling is not working any more
# export FLEETCTL_TUNNEL="$(vagrant ssh-config core-01 | sed -n "s/[ ]*HostName[ ]*//gp"):$(vagrant ssh-config | sed -n "s/[ ]*Port[ ]*//gp")"

fleetctl --endpoint=http://${CLUSTER_MASTER}:4001 list-machines

echo ""
echo "For additional commands:"
echo "fleetctl --endpoint=http://${CLUSTER_MASTER}:4001 ..."