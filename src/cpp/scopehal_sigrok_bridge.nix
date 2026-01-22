{ pkgs, ... }:
let
  # from https://github.com/NixOS/nixpkgs/blob/ab70b01c83dd5ba876d8d79ef5cba24ef185c8c9/pkgs/applications/science/electronics/dsview/libsigrok4dsl.nix
  # No use updating libsigrok4DSL as the sigrok bridge only works on certain version of libsigrok4dsl
  libsigrok4dsl = pkgs.stdenv.mkDerivation {
    pname = "libsigrok4dsl";
    version = "1.12";

    src = pkgs.fetchFromGitHub {
      owner = "DreamSourceLab";
      repo = "DSView";
      rev = "5a9481fd0697d66ce5ce0e46a8d233125e6cb5ac";
      hash = "sha256-4sEseH5OmWsesNj+c+RuAu6Oj4yn8TibaA8MnKLo7h4=";
    };

    postUnpack = ''
      export sourceRoot=$sourceRoot/libsigrok4DSL
    '';

    nativeBuildInputs = with pkgs; [
      pkg-config
      autoreconfHook
    ];

    buildInputs = with pkgs; [
      glib
      libzip
      libserialport
      libusb1
      libftdi
      systemd
      check
      alsa-lib
    ];
  };
in

pkgs.stdenv.mkDerivation {
  pname = "scopehal-sigrok-bridge";
  version = "0-unstable-2022-05-08";

  src = pkgs.fetchFromGitHub {
    owner = "MorganTL";
    repo = "scopehal-sigrok-bridge";
    rev = "e96ebfb310e022faa94307f10004e7230de7aef1";
    hash = "sha256-YRA7rRAE+HCWo7BV9T0rW/2cw5bdIPYrJMKSKbTCUPE=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = with pkgs; [
    cmake
    pkg-config
    libsigrok4dsl
  ];

  buildInputs = with pkgs; [
    glib
    libserialport
    libusb1
    libzip
    pcre2
  ];

  # see https://github.com/NixOS/nixpkgs/pull/73377/files
  # bypass error: format not a string literal and no format arguments
  hardeningDisable = [ "format" ];

  # No install phase in make file
  installPhase = ''
    mkdir -p $out/bin
    cp scopehal-sigrok-bridge $out/bin
  '';

  postPatch = ''
    substituteInPlace src/main.cpp \
      --replace '"/usr/local/share/DSView/res/' '"${libsigrok4dsl.src}/DSView/res/'
    substituteInPlace CMakeLists.txt \
      --replace-fail 'cmake_minimum_required(VERSION 3.3)' 'cmake_minimum_required(VERSION 3.10)'
  '';

}
