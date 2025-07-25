#!/usr/bin/env bash
set -euo pipefail

# One-shot: enter flake container and immediately launch the NixOS VM.
# `--cmd` keeps the session interactive after the VM exits (exec bash).

./cluster2nix.sh --cmd "./nix2nixos-vm.sh && exec bash"