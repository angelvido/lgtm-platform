CLUSTER_NAME ?= lgtm-platform
KUBECONFIG_FILE ?= $(HOME)/.kube/config
CLUSTER_WAIT_TIMEOUT ?= 120s
OBSERVABILITY_NAMESPACE ?= observability
OBSERVABILITY_RELEASE ?= observability
HELM_TIMEOUT ?= 10m
GRAFANA_LOCAL_PORT ?= 3000
GRAFANA_ADMIN_PASSWORD_FILE ?= $(CURDIR)/.secrets/grafana-admin-password
OTEL_TRAFFIC_DURATION ?= 300
OTEL_TRAFFIC_INTERVAL ?= 1
OTEL_TRAFFIC_SERVICE_NAME ?= otel-demo-traffic
OTEL_TRAFFIC_ENDPOINT ?= http://otel-agent:4318

.DEFAULT_GOAL := help

.PHONY: help lint cluster status destroy observability observability-status port-forward otel-traffic destroy-observability

help:
	@printf '%s\n' \
		'Available targets:' \
		'' \
		'  help      Show this help message' \
		'  lint      Run all repository validation checks' \
		'  cluster   Create the local kind cluster' \
		'  status    Show cluster nodes and system pods' \
		'  destroy   Delete the local kind cluster' \
		'  observability         Install or upgrade the observability platform' \
		'  observability-status  Show observability release, pods, and services' \
		'  port-forward          Forward Grafana to a local port' \
		'  otel-traffic          Generate synthetic metrics, logs, and traces' \
		'  destroy-observability Uninstall observability and delete its namespace' \
		'' \
		'Configuration variables:' \
		'' \
		'  CLUSTER_NAME          Cluster name (default: lgtm-platform)' \
		'  KUBECONFIG_FILE       Kubeconfig path (default: $$HOME/.kube/config)' \
		'  CLUSTER_WAIT_TIMEOUT  Node readiness timeout (default: 120s)' \
		'  OBSERVABILITY_NAMESPACE  Platform namespace (default: observability)' \
		'  OBSERVABILITY_RELEASE    Helm release name (default: observability)' \
		'  HELM_TIMEOUT             Helm readiness timeout (default: 10m)' \
		'  GRAFANA_LOCAL_PORT       Local Grafana port (default: 3000)' \
		'  GRAFANA_ADMIN_PASSWORD_FILE  Local Grafana password file' \
		'  OTEL_TRAFFIC_DURATION       Traffic duration in seconds (default: 300)' \
		'  OTEL_TRAFFIC_INTERVAL       Seconds between batches (default: 1)' \
		'  OTEL_TRAFFIC_SERVICE_NAME   Synthetic service name (default: otel-demo-traffic)' \
		'  OTEL_TRAFFIC_ENDPOINT       In-cluster OTLP/HTTP endpoint (default: http://otel-agent:4318)'

lint:
	./scripts/lint.sh

cluster:
	CLUSTER_NAME="$(CLUSTER_NAME)" KUBECONFIG_FILE="$(KUBECONFIG_FILE)" CLUSTER_WAIT_TIMEOUT="$(CLUSTER_WAIT_TIMEOUT)" ./scripts/create-cluster.sh

status:
	CLUSTER_NAME="$(CLUSTER_NAME)" KUBECONFIG_FILE="$(KUBECONFIG_FILE)" ./scripts/cluster-status.sh

destroy:
	CLUSTER_NAME="$(CLUSTER_NAME)" KUBECONFIG_FILE="$(KUBECONFIG_FILE)" ./scripts/destroy-cluster.sh

observability:
	CLUSTER_NAME="$(CLUSTER_NAME)" KUBECONFIG_FILE="$(KUBECONFIG_FILE)" OBSERVABILITY_NAMESPACE="$(OBSERVABILITY_NAMESPACE)" OBSERVABILITY_RELEASE="$(OBSERVABILITY_RELEASE)" HELM_TIMEOUT="$(HELM_TIMEOUT)" GRAFANA_ADMIN_PASSWORD_FILE="$(GRAFANA_ADMIN_PASSWORD_FILE)" ./scripts/deploy-observability.sh

observability-status:
	CLUSTER_NAME="$(CLUSTER_NAME)" KUBECONFIG_FILE="$(KUBECONFIG_FILE)" OBSERVABILITY_NAMESPACE="$(OBSERVABILITY_NAMESPACE)" OBSERVABILITY_RELEASE="$(OBSERVABILITY_RELEASE)" ./scripts/observability-status.sh

port-forward:
	CLUSTER_NAME="$(CLUSTER_NAME)" KUBECONFIG_FILE="$(KUBECONFIG_FILE)" OBSERVABILITY_NAMESPACE="$(OBSERVABILITY_NAMESPACE)" GRAFANA_LOCAL_PORT="$(GRAFANA_LOCAL_PORT)" ./scripts/port-forward-grafana.sh

otel-traffic:
	CLUSTER_NAME="$(CLUSTER_NAME)" KUBECONFIG_FILE="$(KUBECONFIG_FILE)" OBSERVABILITY_NAMESPACE="$(OBSERVABILITY_NAMESPACE)" OTEL_TRAFFIC_DURATION="$(OTEL_TRAFFIC_DURATION)" OTEL_TRAFFIC_INTERVAL="$(OTEL_TRAFFIC_INTERVAL)" OTEL_TRAFFIC_SERVICE_NAME="$(OTEL_TRAFFIC_SERVICE_NAME)" OTEL_TRAFFIC_ENDPOINT="$(OTEL_TRAFFIC_ENDPOINT)" ./scripts/generate-otel-traffic.sh

destroy-observability:
	CLUSTER_NAME="$(CLUSTER_NAME)" KUBECONFIG_FILE="$(KUBECONFIG_FILE)" OBSERVABILITY_NAMESPACE="$(OBSERVABILITY_NAMESPACE)" OBSERVABILITY_RELEASE="$(OBSERVABILITY_RELEASE)" ./scripts/destroy-observability.sh
