#!/bin/sh

# Default to using the local users public key or worst case set of
# previous auth keys
if [ $# -eq 0 ]
then
	[ -e "$HOME/.ssh/id_rsa.pub" ] && FILE_TO_CFGMAP=$HOME/.ssh/id_rsa.pub
	[ -e "$HOME/.ssh/authorized_keys" ] && FILE_TO_CFGMAP=$HOME/.ssh/authorized_keys
else
	FILE_TO_CFGMAP=$1
fi

# https://stackoverflow.com/questions/51268488/kubernetes-configmap-set-from-file-in-yaml-configuration
kubectl create configmap \
	--dry-run=client \
	bastionkey \
	-n bastion \
	--from-file=$FILE_TO_CFGMAP \
	--output yaml > yml/01-cfgmap.yaml
