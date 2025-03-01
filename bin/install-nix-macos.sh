#!/usr/bin/env bash

set -euo pipefail

curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes

if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

nix --version

architecture=`uname -m`
nix-shell -p git --run "git clone https://github.com/jslight90/nix-macos.git /var/lib/nix-macos"
cd /var/lib/nix-macos
nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake .#$architecture
