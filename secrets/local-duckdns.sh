#!/usr/bin/env sh

set -e

if [ "$DUCKDNSTOKEN" = "" ]; then
	echo "\nDUCKDNSTOKEN env must be provided"
	exit 1
fi

kubectl create namespace duckdns || true

kubectl -n duckdns delete secret duckdns-secret || true

kubectl -n duckdns create secret generic duckdns-secret \
	--from-literal=token=$DUCKDNSTOKEN 
