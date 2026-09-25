#!/usr/bin/env bash

set -euo pipefail

readonly CLUSTER_NAME="${CLUSTER_NAME:-lgtm-platform}"
readonly KUBECONFIG_FILE="${KUBECONFIG_FILE:-${HOME}/.kube/config}"
readonly KUBE_CONTEXT="kind-${CLUSTER_NAME}"
readonly OBSERVABILITY_NAMESPACE="${OBSERVABILITY_NAMESPACE:-observability}"
readonly OTEL_TRAFFIC_DURATION="${OTEL_TRAFFIC_DURATION:-300}"
readonly OTEL_TRAFFIC_INTERVAL="${OTEL_TRAFFIC_INTERVAL:-1}"
readonly OTEL_TRAFFIC_SERVICE_NAME="${OTEL_TRAFFIC_SERVICE_NAME:-otel-demo-traffic}"
readonly OTEL_TRAFFIC_ENDPOINT="${OTEL_TRAFFIC_ENDPOINT:-http://otel-agent:4318}"
readonly OTEL_TRAFFIC_JOB_NAME="otel-traffic-generator"
readonly OTEL_TRAFFIC_IMAGE="curlimages/curl:8.12.1"
export KUBECONFIG="${KUBECONFIG_FILE}"

require_command() {
  local command_name="$1"

  if ! command -v "${command_name}" >/dev/null 2>&1; then
    printf 'Error: required command %s is not available in PATH.\n' "${command_name}" >&2
    exit 1
  fi
}

require_positive_integer() {
  local name="$1"
  local value="$2"

  if [[ ! "${value}" =~ ^[1-9][0-9]*$ ]]; then
    printf 'Error: %s must be a positive integer, received %s.\n' "${name}" "${value}" >&2
    exit 1
  fi
}

require_dns_label() {
  local name="$1"
  local value="$2"

  if [[ ! "${value}" =~ ^[a-z0-9]([a-z0-9.-]*[a-z0-9])?$ ]]; then
    printf 'Error: %s must use lowercase letters, numbers, dots, or hyphens.\n' "${name}" >&2
    exit 1
  fi
}

require_command kubectl
require_positive_integer OTEL_TRAFFIC_DURATION "${OTEL_TRAFFIC_DURATION}"
require_positive_integer OTEL_TRAFFIC_INTERVAL "${OTEL_TRAFFIC_INTERVAL}"
require_dns_label OTEL_TRAFFIC_SERVICE_NAME "${OTEL_TRAFFIC_SERVICE_NAME}"

if ! kubectl cluster-info --context "${KUBE_CONTEXT}" >/dev/null 2>&1; then
  printf 'Error: Kubernetes context %s is not reachable. Create the cluster with make cluster.\n' "${KUBE_CONTEXT}" >&2
  exit 1
fi

if ! kubectl get service otel-agent \
  --context "${KUBE_CONTEXT}" \
  --namespace "${OBSERVABILITY_NAMESPACE}" >/dev/null 2>&1; then
  printf 'Error: OpenTelemetry Agent service is not available. Deploy observability with make observability.\n' >&2
  exit 1
fi

remote_script="$(cat <<'REMOTE_SCRIPT'
set -eu

duration="$1"
interval="$2"
service_name="$3"
endpoint="$4"
iterations=$((duration / interval))

if [ "${iterations}" -lt 1 ]; then
  iterations=1
fi

sequence=1
errors=0
start_ns="$(($(date +%s) * 1000000000))"
run_id="$(printf '%016x' "$(date +%s)")"

send_payload() {
  path="$1"
  payload="$2"

  curl --silent --show-error --fail \
    --header 'Content-Type: application/json' \
    --request POST \
    --data-binary "${payload}" \
    "${endpoint}/${path}" >/dev/null
}

while [ "${sequence}" -le "${iterations}" ]; do
  now_ns="$(($(date +%s) * 1000000000))"
  latency_ms="$((40 + sequence % 35))"
  status_code=200
  severity_number=9
  severity_text=INFO
  span_status=STATUS_CODE_OK

  if [ $((sequence % 15)) -eq 0 ]; then
    errors=$((errors + 1))
    latency_ms="$((latency_ms + 250))"
    status_code=500
    severity_number=17
    severity_text=ERROR
    span_status=STATUS_CODE_ERROR
  fi

  trace_id="${run_id}$(printf '%016x' "${sequence}")"
  server_span_id="$(printf '%016x' "${sequence}")"
  database_span_id="$(printf '%016x' "$((sequence + 1000000))")"
  database_start_ns="$((now_ns + 10000000))"
  database_end_ns="$((database_start_ns + 20000000))"
  end_ns="$((now_ns + latency_ms * 1000000))"
  resource_attributes="[{\"key\":\"service.name\",\"value\":{\"stringValue\":\"${service_name}\"}},{\"key\":\"service.namespace\",\"value\":{\"stringValue\":\"lgtm-platform\"}},{\"key\":\"service.instance.id\",\"value\":{\"stringValue\":\"${run_id}\"}},{\"key\":\"deployment.environment.name\",\"value\":{\"stringValue\":\"local\"}}]"

  send_payload v1/traces "{\"resourceSpans\":[{\"resource\":{\"attributes\":${resource_attributes}},\"scopeSpans\":[{\"scope\":{\"name\":\"synthetic-traffic-generator\",\"version\":\"1.0.0\"},\"spans\":[{\"traceId\":\"${trace_id}\",\"spanId\":\"${server_span_id}\",\"name\":\"GET /demo/orders/{id}\",\"kind\":\"SPAN_KIND_SERVER\",\"startTimeUnixNano\":\"${now_ns}\",\"endTimeUnixNano\":\"${end_ns}\",\"attributes\":[{\"key\":\"http.request.method\",\"value\":{\"stringValue\":\"GET\"}},{\"key\":\"http.route\",\"value\":{\"stringValue\":\"/demo/orders/{id}\"}},{\"key\":\"http.response.status_code\",\"value\":{\"intValue\":\"${status_code}\"}},{\"key\":\"demo.sequence\",\"value\":{\"intValue\":\"${sequence}\"}}],\"status\":{\"code\":\"${span_status}\"}},{\"traceId\":\"${trace_id}\",\"spanId\":\"${database_span_id}\",\"parentSpanId\":\"${server_span_id}\",\"name\":\"SELECT demo_orders\",\"kind\":\"SPAN_KIND_CLIENT\",\"startTimeUnixNano\":\"${database_start_ns}\",\"endTimeUnixNano\":\"${database_end_ns}\",\"attributes\":[{\"key\":\"db.system.name\",\"value\":{\"stringValue\":\"postgresql\"}},{\"key\":\"db.operation.name\",\"value\":{\"stringValue\":\"SELECT\"}}],\"status\":{\"code\":\"STATUS_CODE_OK\"}}]}]}]}"

  send_payload v1/metrics "{\"resourceMetrics\":[{\"resource\":{\"attributes\":${resource_attributes}},\"scopeMetrics\":[{\"scope\":{\"name\":\"synthetic-traffic-generator\",\"version\":\"1.0.0\"},\"metrics\":[{\"name\":\"demo_requests_total\",\"description\":\"Synthetic requests generated for Grafana validation\",\"sum\":{\"aggregationTemporality\":\"AGGREGATION_TEMPORALITY_CUMULATIVE\",\"isMonotonic\":true,\"dataPoints\":[{\"startTimeUnixNano\":\"${start_ns}\",\"timeUnixNano\":\"${now_ns}\",\"asInt\":\"${sequence}\"}]}},{\"name\":\"demo_errors_total\",\"description\":\"Synthetic request errors\",\"sum\":{\"aggregationTemporality\":\"AGGREGATION_TEMPORALITY_CUMULATIVE\",\"isMonotonic\":true,\"dataPoints\":[{\"startTimeUnixNano\":\"${start_ns}\",\"timeUnixNano\":\"${now_ns}\",\"asInt\":\"${errors}\"}]}},{\"name\":\"demo_request_duration_ms\",\"description\":\"Synthetic request latency in milliseconds\",\"gauge\":{\"dataPoints\":[{\"timeUnixNano\":\"${now_ns}\",\"asDouble\":${latency_ms}.5}]}}]}]}]}"

  send_payload v1/logs "{\"resourceLogs\":[{\"resource\":{\"attributes\":${resource_attributes}},\"scopeLogs\":[{\"scope\":{\"name\":\"synthetic-traffic-generator\",\"version\":\"1.0.0\"},\"logRecords\":[{\"timeUnixNano\":\"${now_ns}\",\"observedTimeUnixNano\":\"${now_ns}\",\"severityNumber\":\"${severity_number}\",\"severityText\":\"${severity_text}\",\"body\":{\"stringValue\":\"Synthetic order request ${sequence} completed with status ${status_code} in ${latency_ms}ms\"},\"attributes\":[{\"key\":\"event.name\",\"value\":{\"stringValue\":\"demo.order.completed\"}},{\"key\":\"http.response.status_code\",\"value\":{\"intValue\":\"${status_code}\"}},{\"key\":\"demo.sequence\",\"value\":{\"intValue\":\"${sequence}\"}}],\"traceId\":\"${trace_id}\",\"spanId\":\"${server_span_id}\"}]}]}]}"

  if [ $((sequence % 30)) -eq 0 ] || [ "${sequence}" -eq "${iterations}" ]; then
    printf 'Generated %s/%s telemetry batches\n' "${sequence}" "${iterations}"
  fi

  sequence=$((sequence + 1))
  sleep "${interval}"
done

printf 'Synthetic OTLP traffic completed for service %s.\n' "${service_name}"
REMOTE_SCRIPT
)"

printf 'Removing previous traffic generator job when present...\n'
kubectl delete job "${OTEL_TRAFFIC_JOB_NAME}" \
  --context "${KUBE_CONTEXT}" \
  --namespace "${OBSERVABILITY_NAMESPACE}" \
  --ignore-not-found \
  --wait >/dev/null

printf 'Generating OTLP traffic for %s seconds as service %s...\n' \
  "${OTEL_TRAFFIC_DURATION}" \
  "${OTEL_TRAFFIC_SERVICE_NAME}"

kubectl create job "${OTEL_TRAFFIC_JOB_NAME}" \
  --context "${KUBE_CONTEXT}" \
  --namespace "${OBSERVABILITY_NAMESPACE}" \
  --image "${OTEL_TRAFFIC_IMAGE}" \
  -- /bin/sh -c "${remote_script}" _ \
  "${OTEL_TRAFFIC_DURATION}" \
  "${OTEL_TRAFFIC_INTERVAL}" \
  "${OTEL_TRAFFIC_SERVICE_NAME}" \
  "${OTEL_TRAFFIC_ENDPOINT}" >/dev/null

kubectl label job "${OTEL_TRAFFIC_JOB_NAME}" \
  --context "${KUBE_CONTEXT}" \
  --namespace "${OBSERVABILITY_NAMESPACE}" \
  app.kubernetes.io/name=otel-traffic-generator \
  app.kubernetes.io/part-of=lgtm-platform \
  --overwrite >/dev/null

kubectl wait \
  --context "${KUBE_CONTEXT}" \
  --namespace "${OBSERVABILITY_NAMESPACE}" \
  --for=condition=Ready \
  pod \
  --selector "job-name=${OTEL_TRAFFIC_JOB_NAME}" \
  --timeout 120s >/dev/null

printf 'Traffic generator started. Streaming progress until completion...\n'
kubectl logs \
  --context "${KUBE_CONTEXT}" \
  --namespace "${OBSERVABILITY_NAMESPACE}" \
  --follow \
  "job/${OTEL_TRAFFIC_JOB_NAME}"

kubectl wait \
  --context "${KUBE_CONTEXT}" \
  --namespace "${OBSERVABILITY_NAMESPACE}" \
  --for=condition=complete \
  "job/${OTEL_TRAFFIC_JOB_NAME}" \
  --timeout "$((OTEL_TRAFFIC_DURATION + 120))s" >/dev/null

printf 'OTLP traffic generation completed. The Job is retained for log inspection.\n'
