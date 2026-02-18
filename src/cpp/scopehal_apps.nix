{ pkgs, ... }:
let
  version = "0.1.1";
in
pkgs.scopehal-apps.overrideAttrs (oldAttr: {
  inherit version;
  src = pkgs.fetchFromGitHub {
    owner = "ngscopeclient";
    repo = "scopehal-apps";
    rev = "v${version}";
    hash = "sha256-7ZXfxfRa+1fbMj2IDF/boNL/qCy4i9IyMnzIgOZunDw= ";
    fetchSubmodules = true;
  };

  buildInputs =
    oldAttr.buildInputs
    # new dependencies of v0.1.1
    # remove when nixpkg update scopehal to v0.1.1
    ++ (with pkgs; [
      libdatrie
      libdeflate
      libselinux
      libsepol
      libsysprof-capture
      libthai
      libuuid
      libxdmcp
      pcre2
      lerc
      xz
      libwebp
      libxkbcommon
      libepoxy
      libxtst
    ]);
  # Remove old v0.1 patches
  patches = [
    ./dslogic_plus.patch
    ./remove_lsb_release.patch
  ];
})
