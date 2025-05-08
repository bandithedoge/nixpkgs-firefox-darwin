self: super:
let
  sources = builtins.fromJSON (builtins.readFile ./sources.json);
  firefoxPackage = edition:
    super.stdenv.mkDerivation rec {
      inherit (sources."${edition}") version;
      pname = "Firefox";

      buildInputs = [ super.pkgs.undmg ];
      sourceRoot = ".";
      phases = [ "unpackPhase" "installPhase" ];
      installPhase = ''
        runHook preInstall

        mkdir -p $out/Applications
        cp -r Firefox*.app "$out/Applications/"

        runHook postInstall
      '';

      src = super.fetchurl {
        name = "Firefox-${version}.dmg";
        inherit (sources."${edition}") url sha256;
      };

      meta = {
        description = "Mozilla Firefox, free web browser (binary package)";
        homepage = "http://www.mozilla.com/en-US/firefox/";
      };
    };

  floorpPackage = edition:
    super.stdenv.mkDerivation rec {
      inherit (sources."${edition}") version;
      pname = "Floorp";
  
      buildInputs = [ super.pkgs._7zz ];
      sourceRoot = ".";
      phases = [ "unpackPhase" "installPhase" ];
  
      unpackPhase = ''
        runHook preUnpack
        7zz x "$src" -o"$sourceRoot"
        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall
    
        mkdir -p $out/Applications
        cp -r Floorp.app "$out/Applications/"
    
        runHook postInstall
      '';

      src = super.fetchurl {
        name = "Floorp-${version}.dmg";
        inherit (sources."${edition}") url sha256;
      };
  
      meta = {
        description = "Floorp is a new Firefox based browser from Japan with excellent privacy & flexibility.";
        homepage = "https://floorp.app/en";
      };
    };

  librewolfPackage = edition:
    super.stdenv.mkDerivation rec {
      inherit (sources."${edition}") version;
      pname = "Librewolf";

      buildInputs = [ super.pkgs.undmg ];
      sourceRoot = ".";
      phases = [ "unpackPhase" "installPhase" ];
      installPhase = ''
        runHook preInstall

        mkdir -p $out/Applications
        cp -r LibreWolf.app "$out/Applications/"

        runHook postInstall
      '';

      src = super.fetchurl {
        name = "Librewolf-${version}.dmg";
        inherit (sources."${edition}") url sha256;
      };

      meta = {
        description = "Mozilla Firefox, free web browser (binary package)";
        homepage = "http://www.mozilla.com/en-US/firefox/";
      };
    };

  zen-browserPackage = edition:
    super.stdenv.mkDerivation rec {
      inherit (sources."${edition}") version;
      pname = "zen-browser";

      buildInputs = [ super.pkgs.undmg ];
      sourceRoot = ".";
      phases = [ "unpackPhase" "installPhase" ];
      installPhase = ''
        runHook preInstall

        mkdir -p $out/Applications
        cp -r Zen.app "$out/Applications/"

        runHook postInstall
      '';

      src = super.fetchurl {
        name = "Zen-${version}.dmg";
        inherit (sources."${edition}") url sha256;
      };

      meta = {
        description = "Firefox based browser with a focus on privacy and customization";
        homepage = "https://www.zen-browser.app/";
      };
    };
in {
  firefox-bin = firefoxPackage "firefox";
  firefox-beta-bin = firefoxPackage "firefox-beta";
  firefox-devedition-bin = firefoxPackage "firefox-devedition";
  firefox-esr-bin = firefoxPackage "firefox-esr";
  firefox-nightly-bin = firefoxPackage "firefox-nightly";
  librewolf = if super.pkgs.system == "x86_64-darwin" then librewolfPackage "librewolf-x86_64" else librewolfPackage "librewolf-arm64";
  floorp-bin = floorpPackage "floorp-x86_64";
  zen-browser-bin = zen-browserPackage "zen-browser";
}
