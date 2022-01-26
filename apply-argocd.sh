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

echo "\nUpdating the password"
new_password=$(htpasswd -bnBC 10 "" $ARGOPASS | tr -d ':\n')
secret_patch='{"stringData": {
    "admin.password": "'$new_password'",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'
kubectl -n argocd patch secret argocd-secret -p $secret_patch

echo "\nCleaning argocd-initial-admin-secret"
kubectl -n argocd delete secret argocd-initial-admin-secret

echo "\nRestarting and wait for argocd-server"
kubectl rollout restart deployment argocd-server -n argocd
kubectl -n argocd wait deployment argocd-server --for=condition=available

echo "\nApplying root application"
kubectl apply \
	-f Application-Root.yaml

echo "\nDone!"
