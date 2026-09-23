CLUSTER_NAME ?= lgtm-platform
KUBECONFIG_FILE ?= $(HOME)/.kube/config
CLUSTER_WAIT_TIMEOUT ?= 120s

.PHONY: cluster status destroy

cluster:
	CLUSTER_NAME="$(CLUSTER_NAME)" KUBECONFIG_FILE="$(KUBECONFIG_FILE)" CLUSTER_WAIT_TIMEOUT="$(CLUSTER_WAIT_TIMEOUT)" ./scripts/create-cluster.sh

status:
	CLUSTER_NAME="$(CLUSTER_NAME)" KUBECONFIG_FILE="$(KUBECONFIG_FILE)" ./scripts/cluster-status.sh

destroy:
	CLUSTER_NAME="$(CLUSTER_NAME)" KUBECONFIG_FILE="$(KUBECONFIG_FILE)" ./scripts/destroy-cluster.sh
