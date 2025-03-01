#!/usr/bin/env bash

set -euo pipefail

cd /var/lib/nix-macos
nix-shell -p git --run "git pull --force"
darwin-rebuild switch --flake .#eo