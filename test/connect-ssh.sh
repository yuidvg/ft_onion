#!/usr/bin/env bash
# test/connect-ssh.sh
#
# Tests SSH connectivity on port 4242 as required by ft_onion project.
# This verifies that "Access to the server via SSH on port 4242 must be enabled."
#
# The script checks:
# 1. Port 4242 is open and accepting connections
# 2. SSH service is responding on that port
# 3. Basic SSH handshake works (without actually logging in)

set -euo pipefail

SSH_PORT=4242
SSH_HOST=localhost
TIMEOUT=10

echo "[INFO] Testing SSH access on port $SSH_PORT..."

# 1. Check if port is open using netcat
printf "[TEST] Port $SSH_PORT connectivity: "
if timeout $TIMEOUT nc -z "$SSH_HOST" "$SSH_PORT" 2>/dev/null; then
    echo "✓ Port is open"
else
    echo "✗ Port is closed or unreachable"
    exit 1
fi

# 2. Check if SSH service is responding
printf "[TEST] SSH service response: "
# Use ssh with BatchMode to avoid interactive prompts
# ConnectionAttempts=1 to fail fast if service isn't SSH
# ConnectTimeout for quick timeout
ssh_output=$(timeout $TIMEOUT ssh \
    -o BatchMode=yes \
    -o ConnectTimeout=5 \
    -o ConnectionAttempts=1 \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -p "$SSH_PORT" \
    test@"$SSH_HOST" \
    echo "test" 2>&1 || true)

# Check if we got an SSH-related response (not connection refused)
if echo "$ssh_output" | grep -q -E "(Permission denied|password|publickey|SSH|OpenSSH)"; then
    echo "✓ SSH service is responding"
else
    echo "✗ No SSH service detected"
    echo "Debug output: $ssh_output"
    exit 1
fi

# 3. Optional: Try to identify SSH version
printf "[INFO] SSH service info: "
ssh_version=$(timeout 5 nc "$SSH_HOST" "$SSH_PORT" <<< "" 2>/dev/null | head -1 || echo "Unknown")
echo "$ssh_version"

echo "[PASS] SSH on port $SSH_PORT is accessible and working"
