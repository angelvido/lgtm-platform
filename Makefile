CLUSTER_NAME ?= lgtm-platform
KUBECONFIG_FILE ?= $(HOME)/.kube/config
CLUSTER_WAIT_TIMEOUT ?= 120s

.DEFAULT_GOAL := help

.PHONY: help cluster status destroy

help:
	@printf '%s\n' \
		'Available targets:' \
		'' \
		'  help      Show this help message' \
		'  cluster   Create the local kind cluster' \
		'  status    Show cluster nodes and system pods' \
		'  destroy   Delete the local kind cluster' \
		'' \
		'Configuration variables:' \
		'' \
		'  CLUSTER_NAME          Cluster name (default: lgtm-platform)' \
		'  KUBECONFIG_FILE       Kubeconfig path (default: $$HOME/.kube/config)' \
		'  CLUSTER_WAIT_TIMEOUT  Node readiness timeout (default: 120s)'

cluster:
	CLUSTER_NAME="$(CLUSTER_NAME)" KUBECONFIG_FILE="$(KUBECONFIG_FILE)" CLUSTER_WAIT_TIMEOUT="$(CLUSTER_WAIT_TIMEOUT)" ./scripts/create-cluster.sh

status:
	CLUSTER_NAME="$(CLUSTER_NAME)" KUBECONFIG_FILE="$(KUBECONFIG_FILE)" ./scripts/cluster-status.sh

destroy:
	CLUSTER_NAME="$(CLUSTER_NAME)" KUBECONFIG_FILE="$(KUBECONFIG_FILE)" ./scripts/destroy-cluster.sh
