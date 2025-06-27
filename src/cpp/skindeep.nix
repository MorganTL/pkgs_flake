{ pkgs, ... }:
pkgs.stdenv.mkDerivation (self: {
  pname = "skindeep";
  version = "0-unstable-2025-06-26";

  src = pkgs.fetchFromGitHub {
    owner = "DanielGibson";
    repo = "SkinDeep";
    rev = "e55658f01af381f882ee7ae58f4a081a1e63ed11";
    hash = "sha256-VAuyOMFHGU3LZnC30eECCApsIEfnX5Z5fkR14S4uDQY=";
  };
  sourceRoot = "${self.src.name}/neo";

  nativeBuildInputs = with pkgs; [
    cmake
  ];

  buildInputs = with pkgs; [
    libGL
    libGLU
    libjpeg
    libogg
    libvorbis
    openal
    SDL2
    zlib
  ];
})
