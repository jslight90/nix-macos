{
  description = "Effortless nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [
        #vim
        tree
        bind
      ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # Create auto-update service
      systemd.timers.nix-macos-update = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
          Unit = "nix-macos-update.service";
        };
      };
      systemd.services.nix-macos-update = {
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
        script = ''
          /var/lib/nix-macos/bin/update-nix-macos.sh
        '';
      };
    };

    x86_64 = {
      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "x86_64-darwin";
    };

    aarch64 = {
      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#eo
    darwinConfigurations."x86_64" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        x86_64
      ];
    };

    darwinConfigurations."aarch64" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        aarch64
    };
  };
}
