{ pkgs, ... }:
pkgs.stdenv.mkDerivation {
  pname = "scopehal-uhd-bridge";
  version = "0-unstable-2024-01-22";

  src = pkgs.fetchFromGitHub {
    owner = "ngscopeclient";
    repo = "scopehal-uhd-bridge";
    rev = "e9ab04cd5f17743c42b2c4be31754efc122bb3cd";
    hash = "sha256-m6ederJ2hx0M/iIqon4NMjvOQn03wdtF0wZyTlPylpE=";
    # hash = pkgs.lib.fakeHash;
    fetchSubmodules = true;
  };

  nativeBuildInputs = with pkgs; [
    cmake
    pkg-config
    uhd
    boost
  ];

  # see https://github.com/NixOS/nixpkgs/pull/73377/files
  # bypass error: format not a string literal and no format arguments
  hardeningDisable = [ "format" ];

  # NOTE: use  "cp * $out" to check where is the executable
  # No install phase in make file
  installPhase = ''
    mkdir -p $out/bin
    cp src/uhdbridge/uhdbridge $out/bin
  '';
}
