#!/usr/bin/env sh

set -e

if [ "$ARGOPASS" = "" ]; then
	echo "👎 Please provide password for ArgoCD admin user in ARGOPASS env"
	exit 1
fi

echo "\n🧬 Apply ArgoCD to argocd namespace"
argo_password=$(htpasswd -bnBC 10 "" $ARGOPASS | tr -d ':\n')
argo_password_mtime=$(date +%FT%T%Z)

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install \
  argocd argo/argo-cd -n argocd \
  --version "3.31.1" \
  --set 'server.extraArgs={--insecure}' \
  --set "configs.secret.argocdServerAdminPassword=$argo_password" \
  --set "configs.secret.argocdServerAdminPasswordMtime=$argo_password_mtime" \
  --create-namespace --wait

kubectl apply -f root.yaml

echo "\n🎖  Done!"
