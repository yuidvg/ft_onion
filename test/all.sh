#!/usr/bin/env bash
# test/all.sh
#
# Comprehensive test suite for ft_onion project requirements:
# - Access to the static page via HTTP on port 80 must be enabled (via .onion)
# - Access to the server via SSH on port 4242 must be enabled
#
# This script orchestrates both tests and provides a summary.

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
TOR_PROXY=127.0.0.1:9050
SSH_PORT=4242
HTTP_TIMEOUT=25
SSH_TIMEOUT=10

echo -e "${BLUE}=== ft_onion Test Suite ===${NC}"
echo "Testing both HTTP (.onion) and SSH (port 4242) access..."
echo

# Initialize test results
HTTP_RESULT=""
SSH_RESULT=""
OVERALL_SUCCESS=true

# Test 1: HTTP access via Tor Hidden Service
echo -e "${YELLOW}[1/2] Testing HTTP access via Tor Hidden Service${NC}"
echo "----------------------------------------"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -x "$SCRIPT_DIR/get-tor-page.sh" ]]; then
    # If get-tor-page.sh exists and works, use it
    echo "Using existing get-tor-page.sh script..."
    
    # Get .onion address
    ONION=$("$SCRIPT_DIR/../up-onion.sh" | awk '/\.onion/{print $NF}')
    echo "[INFO] Hidden Service: $ONION"
    
    # Test HTTP access
    echo -n "[TEST] HTTP 80 via .onion: "
    for i in $(seq $HTTP_TIMEOUT); do
        code=$(curl --silent --output /dev/null \
                    --socks5-hostname $TOR_PROXY \
                    --write-out '%{http_code}' "http://$ONION/" 2>/dev/null || echo "000")
        
        if [[ "$code" == "200" ]]; then
            echo -e "${GREEN}✓ OK (HTTP $code)${NC}"
            HTTP_RESULT="PASS"
            break
        fi
        
        if [[ $i -eq $HTTP_TIMEOUT ]]; then
            echo -e "${RED}✗ FAIL (HTTP $code after ${HTTP_TIMEOUT}s)${NC}"
            HTTP_RESULT="FAIL"
            OVERALL_SUCCESS=false
        else
            sleep 1
        fi
    done
    
    # Verify page content
    if [[ "$HTTP_RESULT" == "PASS" ]]; then
        echo -n "[TEST] Static page content: "
        body=$(curl --silent --socks5-hostname $TOR_PROXY "http://$ONION/" 2>/dev/null || echo "")
        if echo "$body" | grep -q -i "hidden\|tor\|ft_onion"; then
            echo -e "${GREEN}✓ Content verified${NC}"
        else
            echo -e "${YELLOW}⚠ Content unclear but HTTP works${NC}"
        fi
    fi
    
else
    echo -e "${RED}✗ get-tor-page.sh not found or failed${NC}"
    HTTP_RESULT="FAIL"
    OVERALL_SUCCESS=false
fi

echo

# Test 2: SSH access on port 4242
echo -e "${YELLOW}[2/2] Testing SSH access on port 4242${NC}"
echo "----------------------------------------"

if [[ -x "$SCRIPT_DIR/connect-ssh.sh" ]]; then
    if "$SCRIPT_DIR/connect-ssh.sh"; then
        SSH_RESULT="PASS"
        echo -e "${GREEN}✓ SSH test completed successfully${NC}"
    else
        SSH_RESULT="FAIL"
        OVERALL_SUCCESS=false
        echo -e "${RED}✗ SSH test failed${NC}"
    fi
else
    echo -e "${RED}✗ connect-ssh.sh not found or not executable${NC}"
    SSH_RESULT="FAIL"
    OVERALL_SUCCESS=false
fi

echo

# Summary
echo -e "${BLUE}=== Test Summary ===${NC}"
echo "----------------------------------------"
printf "HTTP (.onion): "
if [[ "$HTTP_RESULT" == "PASS" ]]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
fi

printf "SSH (port 4242): "
if [[ "$SSH_RESULT" == "PASS" ]]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
fi

echo "----------------------------------------"
if $OVERALL_SUCCESS; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED${NC}"
    echo "ft_onion project requirements are satisfied!"
    exit 0
else
    echo -e "${RED}❌ SOME TESTS FAILED${NC}"
    echo "Please check the failed components above."
    exit 1
fi 