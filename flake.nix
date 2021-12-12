{
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/master"; };
  outputs = { self, nixpkgs, ... }@inputs: { overlay = import ./overlay.nix; };
}
