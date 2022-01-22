#!/usr/bin/env sh

set -e

kubectl delete secret docker-registry eu-gcr-auth || true

kubectl create secret docker-registry eu-gcr-auth \
	--docker-server=eu.gcr.io \
	--docker-username=_json_key \
	--docker-password="$GCRJSONAUTH" \
	--docker-email=andrei@chenchik.me

kubectl patch serviceaccount default \
	-p '{"imagePullSecrets": [{"name": "eu-gcr-auth"}]}'
