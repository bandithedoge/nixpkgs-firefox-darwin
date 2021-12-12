# nixpkgs-firefox-darwin

The `firefox` packages in Nixpkgs have been broken on Darwin for ages and the `-bin` variants don't support Darwin at all. This overlay aims to fix that by providing `-bin` packages for Firefox generated from official builds.

## How to use it

Minimal configuration example using flakes and nix-darwin:

```nix
# flake.nix
{
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
        darwin.url = "github:lnl7/nix-darwin/master";
        darwin.inputs.nixpkgs.follows = "nixpkgs";
        nixpkgs-firefox-darwin = "github:bandithedoge/nixpkgs-firefox-darwin";
    };

    outputs = { self, darwin, nixpkgs, ... }@inputs: {
        darwinConfigurations."machine" = darwin.lib.darwinSystem {
            system = "x86_64-darwin";
            modules = [
                { nixpkgs.overlays = [ inputs.firefox-darwin.overlay ]; }
                ./configuration.nix
            ];
        };
    };
}
```

## How it works

The entire overlay is controlled by a script that fetches release information from Mozilla and puts the version, URL and SHA256 in a JSON file. The JSON gets imported by a Nix expression and the values are used to build a derivation. The script can be run manually or with a GitHub action.

## TODO

- [ ] Firefox Nightly
- [ ] Non-flake compatibility
