# nixpkgs-firefox-darwin

The `firefox` packages in Nixpkgs have been broken on Darwin for ages and the `-bin` variants don't support Darwin at all. This overlay aims to fix that by providing `-bin` packages for Firefox generated from official builds.

## How to use it

Minimal configuration example using flakes, nix-darwin and home-manager:

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:lnl7/nix-darwin/master";
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";
  };

  outputs = { self, darwin, home-manager, nixpkgs, ... }@inputs: {
    darwinConfigurations."machine" = let
      # replace this with your username, obviously
      username = "bandithedoge";
    in darwin.lib.darwinSystem {
      system = "x86_64-darwin";
      modules = [
        home-manager.darwinModules.home-manager
        {
          nixpkgs.overlays = [ inputs.nixpkgs-firefox-darwin.overlay ];
          home-manager.users.${username} = {
            programs.firefox = {
              enable = true;

              # IMPORTANT: use a package provided by the overlay (ends with `-bin`)
              # see overlay.nix for all possible packages
              package = pkgs.firefox-bin;
            };
          };
        }
      ];
    };
  };
}
```

## How it works

The entire overlay is controlled by a script that fetches release information from Mozilla and puts the version, URL and SHA256 in a JSON file. The JSON gets imported by a Nix expression and the values are used to build a derivation. The script can be run manually or with a GitHub action.
