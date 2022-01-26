#!/usr/bin/env sh

set -e

if [ "$ARGOPASS" = "" ]; then
	echo "👎 Please provide password for ArgoCD admin user in ARGOPASS env"
	exit 1
fi

echo "\n🧬 Apply ArgoCD to argocd namespace"
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install \
  argocd argo/argo-cd -n argocd \
  --set 'server.extraArgs={--insecure}' \
  --create-namespace --wait

echo "\n🔓 Update the ArgoCD password"
new_password=$(htpasswd -bnBC 10 "" $ARGOPASS | tr -d ':\n')
secret_patch='{"stringData": {
    "admin.password": "'$new_password'",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'
kubectl -n argocd patch secret argocd-secret -p "$secret_patch"

echo "\n🗑  Clean default argocd-initial-admin-secret if exists"
kubectl -n argocd delete secret argocd-initial-admin-secret || true

echo "\n🤖 Restart and wait for argocd-server"
kubectl rollout restart deployment argocd-server -n argocd
kubectl -n argocd wait deployment argocd-server --for=condition=available

echo "\n🚀 Apply root application"
kubectl apply \
	-f Application-Root.yaml

echo "\n🎖  Done!"
