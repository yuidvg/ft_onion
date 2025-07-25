#!/usr/bin/env bash
# up-onion.sh – Spin up the docker-compose stack and print the generated .onion address.
#
# Usage:
#   ./up-onion.sh              # start all services
#   ./up-onion.sh tor          # start only tor (and its deps)
#
# The script waits until Tor has created /var/lib/tor/hidden_service/hostname
# inside the tor container, then prints the address so you can copy-paste it
# into your browser / curl / etc.

set -eu -o pipefail

SERVICES="$*"

# Bring services up (defaults to all if none specified)
if [ -z "$SERVICES" ]; then
  echo "[up-onion] Starting all services with docker compose up -d ..."
  docker compose up -d
else
  echo "[up-onion] Starting selected services: $SERVICES ..."
  docker compose up -d $SERVICES
fi

echo "[up-onion] Waiting for Tor hidden service hostname ..."
# Get tor container name/ID managed by compose (first matching service)
TOR_CID=$(docker compose ps -q tor)
if [ -z "$TOR_CID" ]; then
  echo "[up-onion] ERROR: Tor container is not running. Exiting." >&2
  exit 1
fi

# Loop until hostname file appears inside the container
until docker compose exec -T tor test -f /var/lib/tor/hidden_service/hostname 2>/dev/null; do
  sleep 1
  printf '.'
done
printf '\n'

ONION_ADDR=$(docker compose exec -T tor cat /var/lib/tor/hidden_service/hostname | tr -d '\r')

cat <<EOF
[up-onion] Tor hidden service is ready!
[up-onion] .onion address: $ONION_ADDR
EOF
