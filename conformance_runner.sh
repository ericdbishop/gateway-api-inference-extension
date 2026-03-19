#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ------------------------------------------------------------------------------
# Script: conformance_runner.sh
# Purpose: <describe what this script does>
# Usage:   ./conformance_runner.sh [options]
# ------------------------------------------------------------------------------

usage() {
  cat <<'EOF'
Usage:
  conformance_runner.sh [options]
EOF
}

main() {
  kubectl create namespace conformance-runner
  kubectl -n conformance-runner create serviceaccount conformance-runner

  kubectl create clusterrolebinding conformance-default-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=conformance-runner:default

  docker build -f Dockerfile.conformance -t gaie-conformance-build:local .

  kind load docker-image gaie-conformance-build:local --name kind

  kubectl -n conformance-runner create job gaie-gw-destination-endpoint-served \
  --image=gaie-conformance-build:local \
  -- /work/conformance.test \
     -test.v \
     -gateway-class istio -debug true
}

main "$@"
