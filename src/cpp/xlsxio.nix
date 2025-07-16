{ pkgs, ... }:
pkgs.stdenv.mkDerivation (finalAttr: {
  pname = "xlsxio_xlsx2csv";
  version = "0.2.35";

  src = pkgs.fetchFromGitHub {
    owner = "brechtsanders";
    repo = "xlsxio";
    rev = finalAttr.version;
    hash = "sha256-3f74VMSCPLVRTdXSX/bIcEZFiBp4Xgxd+Ed4PKi4CpA=";
  };

  buildInputs = with pkgs; [
    cmake
    expat
    minizip
    zlib
  ];
})
