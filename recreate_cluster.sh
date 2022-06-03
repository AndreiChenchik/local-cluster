#!/usr/bin/env bash

set -e

export PULUMI_CONFIG_PASSPHRASE="local"

k3d cluster delete local || true
k3d cluster create -c k3d.yaml

pulumi stack rm local --force --yes || true
pulumi stack init local
pulumi up --yes

echo "🎉 Your cluster is ready!"
