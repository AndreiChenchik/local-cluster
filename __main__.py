from datetime import datetime, timezone

import bcrypt
from pydantic import BaseSettings
from pulumi_kubernetes.helm.v3 import (
    Release,
    ReleaseArgs,
    RepositoryOptsArgs,
)
from pulumi_kubernetes.core.v1 import Namespace, Secret


class Config(BaseSettings):
    ARGOCD_PASSWORD: bytes
    GCR_DOCKERJSON_TOKEN: str
    DUCKDNS_TOKEN: str

    class Config:
        case_sensitive = True
        env_prefix: str = "CLUSTER_"


settings = Config()


# Secrets
# apps/duckdns.yaml
duckdns_namespace = Namespace("duckdns_namespace", metadata={"name": "duckdns"})
duckdns_secret = Secret(
    "duckdns_secret",
    string_data={"token": settings.DUCKDNS_TOKEN},
    metadata={"name": "duckdns-secret", "namespace": "duckdns"},
)

# apps/Application-API.yaml
enableops_api_namespace = Namespace(
    "enableops_api_namespace", metadata={"name": "enableops-api"}
)
eugcrio_pullsecret = Secret(
    "eugcrio_pullsecret",
    data={".dockerconfigjson": settings.GCR_DOCKERJSON_TOKEN},
    metadata={"name": "eu-gcr-io", "namespace": "enableops-api"},
    type="kubernetes.io/dockerconfigjson",
)

# ArgoCD
password_hash = bcrypt.hashpw(settings.ARGOCD_PASSWORD, bcrypt.gensalt())
argocd_password = password_hash.decode()
modify_time = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S%Z")

root_app = {
    "name": "root",
    "namespace": "argocd",
    "project": "default",
    "destination": {
        "server": "https://kubernetes.default.svc",
    },
    "syncPolicy": {
        "automated": {
            "prune": True,
            "selfHeal": True,
            "allowEmpty": True,
        },
        "syncOptions": ["Validate=true", "CreateNamespace=true"],
    },
    "source": {
        "repoURL": "https://github.com/AndreiChenchik/local-cluster",
        "path": "apps",
        "targetRevision": "HEAD",
    },
}

release_values = {
    "configs": {
        "secret": {
            "argocdServerAdminPassword": argocd_password,
            "argocdServerAdminPasswordMtime": modify_time,
        }
    },
    "server": {
        "extraArgs": ["--insecure"],
        "additionalApplications": [root_app],
    },
}

argocd_namespace = Namespace("argocd", metadata={"name": "argocd"})

release_args = ReleaseArgs(
    chart="argo-cd",
    repository_opts=RepositoryOptsArgs(
        repo="https://argoproj.github.io/argo-helm"
    ),
    version="3.31.1",
    name="argocd",
    namespace=argocd_namespace.metadata["name"],
    values=release_values,
)

argocd = Release("argocd", args=release_args)
