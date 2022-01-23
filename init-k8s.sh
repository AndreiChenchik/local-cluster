#!/usr/bin/env sh

set -e

if [ "$ARGOPASS" = "" ]; then
	echo "Please provide password for ArgoCD admin user in ARGOPASS env"
	exit 1
fi

if [ "$1"="reset" ]; then
	echo "\nRemoving existing ArgoCDs namespaces"
	kubectl delete namespace argocd
	kubectl delete namespace argocd-apps
fi

echo "\nCreating ArgoCDs namespaces"
kubectl create namespace argocd
kubectl create namespace argocd-apps

echo "\nApplying ArgoCD to argocd namespace"
kubectl apply -n argocd \
	-f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "\nWaiting for ArgoCD to become available"
kubectl -n argocd wait deployment argocd-server --for=condition=available

random_password=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)

echo "\nAuthentificating and updating the password"
argocd login --name local --username admin --password $random_password --port-forward-namespace argocd --port-forward
argocd account update-password --account admin --current-password $random_password --new-password $ARGOPASS --port-forward-namespace argocd

echo "\nCleaning argocd-initial-admin-secret"
kubectl -n argocd delete secret argocd-initial-admin-secret


if [ "$GCRJSONAUTH" = "" ]; then
	echo "\nGCRJSONAUTH env not provided, skipping GCR auth"
else
	echo "\nConfiguring auth for eu.gcr.io"

	kubectl -n argocd-apps create secret docker-registry eu-gcr-io \
		--docker-server=eu.gcr.io \
		--docker-username=_json_key \
		--docker-password="$GCRJSONAUTH" \
		--docker-email=andrei@chenchik.me
fi

echo "\nInstalling traefik ingress controller"
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install traefik traefik/traefik

echo "\nApplying root application"
kubectl apply \
	-f root-app.yaml

echo "\nDone!"
