#!/usr/bin/env bash

# This script starts a local Hugo server in a Docker container to aid in local development.
# In order to view also draft content, the server is started with the `--buildDrafts` flag.

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
ROOT_PATH="$(cd "${SCRIPT_DIR}"/.. && pwd)"

: "${CONTAINER_REGISTRY:=}"
: "${CONTAINER_IMAGE:=klakegg/hugo}"
: "${CONTAINER_NAME:=kubermatic-docs}"
: "${HUGO_VERSION:=0.101.0-ext}"
: "${HUGO_PORT:=8080}"
: "${HUGO_SERVER_ARGS:=--buildDrafts --navigateToChanged --noHTTPCache}"
: "${CONTAINER_RUNTIME:=docker}"
: "${CONTAINER_RUN_OPTIONS:=--user $(id --user):$(id --group)}"
: "${CONTAINER_MNT_OPTIONS:=}"

echo "[INFO] Staring Hugo server with image '${CONTAINER_REGISTRY}${CONTAINER_IMAGE}:${HUGO_VERSION}' ..."

is_running="$($CONTAINER_RUNTIME inspect -f '{{ .State.Running }}' "${CONTAINER_NAME}" 2>/dev/null || true)"

if [[ "${is_running}" != "true" ]]; then
  $CONTAINER_RUNTIME run --rm --detach ${CONTAINER_RUN_OPTIONS} \
    --volume "${ROOT_PATH}:/src${CONTAINER_MNT_OPTIONS}" \
    --publish "${HUGO_PORT}:${HUGO_PORT}" \
    --name "${CONTAINER_NAME}" \
      "${CONTAINER_REGISTRY}${CONTAINER_IMAGE}:${HUGO_VERSION}" \
      server --port ${HUGO_PORT} ${HUGO_SERVER_ARGS}

  echo "[INFO] Successfully started Hugo. Visit your site at http://localhost:${HUGO_PORT} !"
else
  echo "[INFO] Hugo is already running. Visit your site at http://localhost:${HUGO_PORT} !"
fi
