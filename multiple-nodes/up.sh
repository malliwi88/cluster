#!/bin/bash

cp ../_setup/* .
CLUSTER_SIZE=3 vagrant up
vagrant ssh-config core-01 | sed -n "s/IdentityFile//gp" | xargs ssh-add
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
export FLEETCTL_TUNNEL="$(vagrant ssh-config core-01 | sed -n "s/[ ]*HostName[ ]*//gp"):$(vagrant ssh-config | sed -n "s/[ ]*Port[ ]*//gp")"
fleetctl list-machines