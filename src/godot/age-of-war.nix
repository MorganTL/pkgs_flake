{ pkgs, ... }:
let
  # referencing https://github.com/NixOS/nixpkgs/blob/2349f9de17183971db12ae9e0123dab132023bd7/pkgs/by-name/pi/pixelorama/package.nix#L7
  godot = pkgs.godot_4_3;
in
pkgs.stdenv.mkDerivation {
  pname = "age-of-war";
  version = "1.0";

  src = pkgs.fetchFromGitHub {
    owner = "apiotrowski255";
    repo = "age-of-war";
    rev = "3cc8e802c381795f8c4b47abe54d1569e5249d60";
    hash = "sha256-ez99ZVJyRZS4pFmerNPGUUJWFKoOEeOcNrjYb+gTa20=";
  };

  nativeBuildInputs = [
    godot
  ];

  # Add back export preset for godot headless export
  patches = [
    ./0001-add-back-export_presets.cfg.patch
  ];

  buildPhase = ''
    runHook preBuild

    # Cannot create file '/homeless-shelter/.config/godot/projects/...'
    export HOME=$TMPDIR

    # Link the export-templates to the expected location. The --export commands
    # expects the template-file at .../templates/{godot-version}.stable/linux_x11_64_release
    mkdir -p $HOME/.local/share/godot/
    ln -s "${godot.export-template}"/share/godot/export_templates "$HOME"/.local/share/godot/

    mkdir -p build
    godot4 --headless --export-release "Linux" ./build/age-of-war

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -D -m 755 -t $out/libexec ./build/age-of-war
    install -D -m 644 -t $out/libexec ./build/age-of-war.pck
    install -d -m 755 $out/bin
    ln -s $out/libexec/age-of-war $out/bin/age-of-war
      
    runHook postInstall
  '';
}
