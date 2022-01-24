#!/usr/bin/env sh

set -e

if [ "$GCRJSONAUTH" = "" ]; then
	echo "\nGCRJSONAUTH env must be provided"
	exit 1
fi

kubectl --context gke_enableops-infra_us-central1-f_outpost \
	-n enableops-api \
	delete secret eu-gcr-puller \
	|| true

kubectl --context gke_enableops-infra_us-central1-f_outpost \
	-n enableops-api \
	create secret docker-registry eu-gcr-puller \
	--docker-server=eu.gcr.io \
	--docker-username=_json_key \
	--docker-password="$GCRJSONAUTH" \
	--docker-email=andrei@chenchik.me
