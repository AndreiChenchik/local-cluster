#!/usr/bin/env sh

set -e 

kubectl create namespace enableops-api || true
kubectl -n enableops-api delete secret python-env || true

kubectl -n enableops-api create secret generic python-env \
	--from-literal=API_SENTRY_DSN=$API_SENTRY_DSN \
	--from-literal=API_SECURITY__SESSION_SIGN_KEY=$API_SECURITY__SESSION_SIGN_KEY \
	--from-literal=API_SECURITY__DB_CRYPTO_KEY=$API_SECURITY__DB_CRYPTO_KEY \
	--from-literal=API_OAUTH__CLIENT_ID=$API_OAUTH__CLIENT_ID \
	--from-literal=API_OAUTH__CLIENT_SECRET=$API_OAUTH__CLIENT_SECRET \
	--from-literal=API_GITHUB__TOKEN=$API_GITHUB__TOKEN \
	--from-literal=API_DB__HEROKU_API_KEY=$API_DB__HEROKU_API_KEY \
	--from-literal=API_ENV_STATE=$API_ENV_STATE \
	--from-literal=API_SECURITY__TERRAFORM_SECRET=$API_SECURITY__TERRAFORM_SECRET

