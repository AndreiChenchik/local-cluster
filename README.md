# local-cluster

My personal setup of local "cloud" environment, may be useful for someone.

## How to deploy

0. Clone the repo

```
git clone https://github.com/AndreiChenchik/local-cluster.git
cd local-cluster
```

1. Get active _kubectl context_
   I'm using [k3d](https://k3d.io/), but you can use [built-in kubernetes cluster from Docker](https://docs.docker.com/desktop/kubernetes/), or connect to any other cluster, but I don't advice you to use this configuration on any real clusters, this supposed to be a **local deployment only**.

```bash
k3d cluster create -c k3d.yaml
```

2. Deploy apps
   The command below will deploy the [fluxcd](https://fluxcd.io/) using [pulumi](https://www.pulumi.com/) and then **fluxcd** will deploy all the apps and will be doing GitOps by watching this repo for any changes.

```bash
pulumi up
```

**Pulumi** is used to provide cluster with secrets needed for operation.
