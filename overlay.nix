self: super: let
  sources = builtins.fromJSON (builtins.readFile ./sources.json);

  firefoxPackage = args @ {
    edition,
    extraFiles ? {},
    ...
  }:
    super.stdenv.mkDerivation (rec {
        inherit (sources."${edition}") version;
        pname = "Firefox";

        buildInputs = [super.pkgs.undmg];
        sourceRoot = ".";
        phases = ["unpackPhase" "installPhase"];

        extraFilesPaths = builtins.map (x: x.source) (builtins.attrValues extraFiles);
        extraFilesTargets = builtins.attrNames extraFiles;
        extraFilesRecursive = builtins.map (x:
          if x.recursive or false
          then "true"
          else "false") (builtins.attrValues extraFiles);

        installPhase = ''
          runHook preInstall

          mkdir -p $out/Applications
          cp -r Firefox*.app "$out/Applications/"

          if [ -n "$extraFilesPaths" ]; then
            extraFilesPathsArr=($extraFilesPaths)
            extraFilesTargetsArr=($extraFilesTargets)
            extraFilesRecursiveArr=($extraFilesRecursive)

            for i in "''${!extraFilesPathsArr[@]}"; do
              source_path="''${extraFilesPathsArr[$i]}"
              target_path_suffix="''${extraFilesTargetsArr[$i]}"
              recursive_copy="''${extraFilesRecursiveArr[$i]}"

              target_base_dir="$out/Applications/Firefox.app/Contents/Resources"
              full_target_path="$target_base_dir/$target_path_suffix"

              mkdir -p "$(dirname "$full_target_path")"

              if [[ "$recursive_copy" == "true" ]]; then
                mkdir -p "$full_target_path"
                echo "Copying directory $source_path to $full_target_path"
                cp -R "$source_path/"* "$full_target_path/"
              else
                echo "Copying file $source_path to $full_target_path"
                cp "$source_path" "$full_target_path"
              fi
            done
          fi

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
      }
      // builtins.removeAttrs args ["edition" "extraFiles"]);

  floorpPackage = edition:
    super.stdenv.mkDerivation rec {
      inherit (sources."${edition}") version;
      pname = "Floorp";

      buildInputs = [super.pkgs._7zz];
      sourceRoot = ".";
      phases = ["unpackPhase" "installPhase"];

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

      buildInputs = [super.pkgs.undmg];
      sourceRoot = ".";
      phases = ["unpackPhase" "installPhase"];
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

      buildInputs = [super.pkgs.undmg];
      sourceRoot = ".";
      phases = ["unpackPhase" "installPhase"];
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
  firefox-bin = super.lib.makeOverridable firefoxPackage {edition = "firefox";};
  firefox-beta-bin = super.lib.makeOverridable firefoxPackage {edition = "firefox-beta";};
  firefox-devedition-bin = super.lib.makeOverridable firefoxPackage {edition = "firefox-devedition";};
  firefox-esr-bin = super.lib.makeOverridable firefoxPackage {edition = "firefox-esr";};
  firefox-nightly-bin = super.lib.makeOverridable firefoxPackage {edition = "firefox-nightly";};
  librewolf =
    if super.pkgs.system == "x86_64-darwin"
    then librewolfPackage "librewolf-x86_64"
    else librewolfPackage "librewolf-arm64";
  floorp-bin = floorpPackage "floorp-x86_64";
  zen-browser-bin = zen-browserPackage "zen-browser";
}