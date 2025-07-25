#!/usr/bin/env bash
#
# get-tor-page.sh
#
# Fetches a web page from a .onion address using a local Tor SOCKS proxy.
# The .onion hostname (without http://) should be provided as the first argument.
#
# Usage:
#   ./get-tor-page.sh <onion_hostname>

set -euo pipefail

main() {
  # Ensure a command-line argument is provided.
  if [ -z "${1:-}" ]; then
    echo "Error: No .onion hostname provided." >&2
    echo "Usage: $0 <onion_hostname>" >&2
    exit 1
  fi

  # Accept both a full URL (http(s)://foo.onion[/path]) or a bare hostname (foo.onion).
  # If the argument already starts with http:// or https://, use it verbatim; otherwise
  # prepend "http://" so that curl gets a proper URL.

  readonly INPUT="$1"
  if [[ "$INPUT" =~ ^https?:// ]]; then
    readonly URL="$INPUT"
  else
    readonly URL="http://${INPUT}"
  fi

  # Use curl to fetch the page via the Tor SOCKS proxy.
  # --socks5-hostname: Delegates hostname resolution to the SOCKS5 proxy,
  #                    which is necessary for resolving .onion addresses.
  # -L: Follows HTTP redirects.
  curl --socks5-hostname localhost:9050 -L "${URL}"
}

# Execute the main function with all script arguments.
main "$@"
