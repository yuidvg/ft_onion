#!/usr/bin/env bash
set -Eeuo pipefail

# Start Docker daemon inside the container (Docker-in-Docker)
# Disable automatic TLS cert generation (not needed in trusted dev env)
export DOCKER_TLS_CERTDIR=""

# Start dockerd in background
STORAGE_DRIVER=${DOCKER_DIND_STORAGE_DRIVER:-overlay2}
(
  dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375 \
          --storage-driver=${STORAGE_DRIVER} &
) &

# Wait for dockerd
max=30
count=0
until docker info >/dev/null 2>&1; do
  ((count++))
  if [[ $count -ge $max ]]; then
    echo "[ERROR] dockerd failed to start" >&2
    exit 1
  fi
  sleep 1
done

echo "[INFO] dockerd is running. Executing command: $*"
exec "$@" 