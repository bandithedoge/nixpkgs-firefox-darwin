{ pkgs ? import <nixpkgs> { overlays = [ (import ./overlay.nix) ]; } }:
pkgs.mkShell {
  packages = with pkgs; [
    firefox-bin
    firefox-beta-bin
    firefox-devedition-bin
    firefox-esr-bin
    firefox-nightly-bin
  ];
}
