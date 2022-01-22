#!/usr/bin/env sh

set -e

if [ "$GCRJSONAUTH" = "" ]; then
	echo "Please provide GCR Auth JSON in GCRJSONAUTH env"
	exit 1
fi

kubectl delete secret eu-gcr-io || true

kubectl create secret docker-registry eu-gcr-io \
	--docker-server=eu.gcr.io \
	--docker-username=_json_key \
	--docker-password="$GCRJSONAUTH" \
	--docker-email=andrei@chenchik.me

kubectl patch serviceaccount default \
	-p '{"imagePullSecrets": [{"name": "eu-gcr-io"}]}'
