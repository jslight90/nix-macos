#!/usr/bin/env bash

set -euo pipefail

architecture=`uname -m`
cd /var/lib/nix-macos
nix-shell -p git --run "git fetch"
changes=`nix-shell -p git --run "git rev-list HEAD..origin/main --count"`
if [ $changes -ne 0 ]; then
  nix-shell -p git --run "git pull --force"
  darwin-rebuild switch --flake .#$architecture
fi
