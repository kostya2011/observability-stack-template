# observability-stack-template
[![main](https://github.com/kostya2011/observability-stack-template/actions/workflows/main.yaml/badge.svg)](https://github.com/kostya2011/observability-stack-template/actions/workflows/main.yaml)

This repo is a minimized example of deploying observability stack to k8s.

## Prerequisites

The following dependencies needs to be installed on the local machine to work with template:
- [minikube](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Fx86-64%2Fstable%2Fbinary+download)
- [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [helm](https://helm.sh/docs/intro/install/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [yq](https://github.com/mikefarah/yq) - **Not required, used only for startup script**

## Current list of components

- Grafana
- Loki
- Prometheus
- Promtail
- Echo server app for demo purposes
- Python demo app for demo purposes

## Quickstart

To quickly deploy all componets for observability stack template, the startup script can be used:
```bash
✍️  Usage: ./scripts/start.sh <command>
	Please specify a command to run.
	Example: ./scripts/start.sh apply - to create minikube cluster and install observabilitty stack dependecies + demo apps.
	Example: ./scripts/start.sh destroy - to destroy created components.
```

To deploy all componets, invoke `apply` command: 
```bash
> ./scripts/start.sh apply
✍️  Starting script...
✍️  Checking dependencies.
✅ All needed dependencies are installed.
✍️  This will create minikube cluster and install obesrvability stack. Do you wish to proceed? [y/n]
```

To cleanup all deployed components and minikube cluster, invoke `destroy` command:
```bash
> ./scripts/start.sh destroy
✍️  Starting script...
✍️  Checking dependencies.
✅ All needed dependencies are installed.
✍️  This will delete minikube cluster and uninstall obesrvability stack. Do you wish to proceed? [y/n]
```

> **_NOTE:_**\
> ✍️  Script does not shutdown the minikube cluster and does not uninstall helm resources automatically!


## Manual operations

It's possible to omit startup script and operate with observability stack via plain minikube and terraform commands.
Please use following guides for that:
- https://minikube.sigs.k8s.io/docs/handbook/controls/
- https://developer.hashicorp.com/terraform/tutorials

Also it's possible to deploy only part of observability stack components by overriding variables declared in [variables file](variables.tf).\
Please use the following guide to get more context on terraform variables:
- https://developer.hashicorp.com/terraform/language/values/variables
