{ lib, pkgs, ... }:
let
  # referencing
  # https://github.com/NixOS/nixpkgs/blob/2349f9de17183971db12ae9e0123dab132023bd7/pkgs/by-name/pi/pixelorama/package.nix#L7
  godot = pkgs.godot_4_3;
  godot_version_folder = lib.replaceStrings [ "-" ] [ "." ] godot.version;
in
pkgs.stdenv.mkDerivation {
  pname = "age-of-war";
  version = "1.0";

  src = pkgs.fetchFromGitHub {
    owner = "apiotrowski255";
    repo = "age-of-war";
    rev = "9bd71ea6570e150d5070f655887143e3c207213b";
    hash = "sha256-gExkcbQaV4k2XqNlh3XcNXC7QhZ3wnIe/B2+ESQzptY=";
  };

  nativeBuildInputs = [
    pkgs.autoPatchelfHook
    godot
  ];

  runtimeDependencies = with pkgs; [
    alsa-lib
    libGL
    libpulseaudio
    udev
    vulkan-loader
    xorg.libX11
    xorg.libXcursor
    xorg.libXext
    xorg.libXi
    xorg.libXrandr
  ];

  buildPhase = ''
    runHook preBuild

    # Cannot create file '/homeless-shelter/.config/godot/projects/...'
    export HOME=$TMPDIR

    # Link the export-templates to the expected location. The --export commands
    # expects the template-file at .../templates/{godot-version}.stable/linux_x11_64_release
    mkdir -p $HOME/.local/share/godot/export_templates
    ln -s "${godot.export-templates-bin}" "$HOME/.local/share/godot/export_templates/${godot_version_folder}"

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
