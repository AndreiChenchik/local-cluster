#!/usr/bin/env sh

set -e

if [ "$ARGOPASS" = "" ]; then
	echo "Please provide password for ArgoCD admin user in ARGOPASS env"
	exit 1
fi

echo "\nApplying ArgoCD to argocd namespace"
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd -n argocd --create-namespace --wait --set 'server.extraArgs={--insecure}'

random_password=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)

echo "\nAuthentificating and updating the password"
argocd login --name local --username admin --password $random_password --port-forward-namespace argocd --port-forward --insecure
argocd account update-password --account admin --current-password $random_password --new-password $ARGOPASS --insecure --port-forward-namespace argocd

echo "\nCleaning argocd-initial-admin-secret"
kubectl -n argocd delete secret argocd-initial-admin-secret

echo "\nApplying root application"
kubectl apply \
	-f root-app.yaml

echo "\nDone!"
