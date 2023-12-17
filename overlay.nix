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
        mkdir -p $out/Applications
        cp -r Firefox*.app "$out/Applications/"
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

in {
  firefox-bin = firefoxPackage "firefox";
  firefox-beta-bin = firefoxPackage "firefox-beta";
  firefox-devedition-bin = firefoxPackage "firefox-devedition";
  firefox-esr-bin = firefoxPackage "firefox-esr";
  firefox-nightly-bin = firefoxPackage "firefox-nightly";
}
