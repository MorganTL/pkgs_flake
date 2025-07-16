{ pkgs, ... }:
pkgs.stdenv.mkDerivation (finalAttr: {
  pname = "c47";
  version = "00.109.02.07b12";

  src = pkgs.fetchFromGitLab {
    owner = "rpncalculators";
    repo = "c43";
    rev = finalAttr.version;
    hash = "sha256-wDzSeX7DDdU6Q7L5rgwdm6BeJcLbPTuEzapszn9Qaks=";
  };

  buildInputs = with pkgs; [
    doxygen
    freetype
    git
    gnumake
    gtk3
    libpulseaudio
    meson
    pkg-config
    (python3.withPackages (
      ps: with ps; [
        breathe
        ninja
      ]
    ))
    (pkgs.callPackage ./xlsxio.nix { })
  ];

  # meson must be called via Makefile
  dontUseMesonConfigure = true;

  preConfigure = ''
    patchShebangs tools/onARaspberry
    # https://nixos.org/manual/nixpkgs/stable/#fun-substituteInPlace
    # prevent crashing but almost all asset are hardcoded :<
    substituteInPlace src/c47/defines.h \
      --replace-warn res/c47_pre.css $src/res/c47_pre.css
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ${finalAttr.pname} $out/bin
  '';
})
