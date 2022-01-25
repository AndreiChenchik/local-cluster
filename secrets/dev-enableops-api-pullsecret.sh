#!/usr/bin/env sh

set -e

if [ "$GCRJSONAUTH" = "" ]; then
	echo "\nGCRJSONAUTH env must be provided"
	exit 1
fi
kubectl create namespace enableops-api || true
kubectl -n enableops-api delete secret eu-gcr-io || true

kubectl -n enableops-api create secret docker-registry eu-gcr-io \
  --docker-server=eu.gcr.io \
  --docker-username=_json_key \
  --docker-password="$GCRJSONAUTH" \
  --docker-email=andrei@chenchik.me
