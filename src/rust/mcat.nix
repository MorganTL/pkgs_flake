{ pkgs, ... }:
pkgs.rustPlatform.buildRustPackage (finalAttrs: {
  version = "0.4.0";
  pname = "mcat";

  src = pkgs.fetchFromGitHub {
    owner = "Skardyy";
    repo = "mcat";
    rev = "v${finalAttrs.version}";
    hash = "sha256-8Pk/Um7M5dINV/ZQRRkSiWcE7cCHwE+b5+IFKwlhWxU=";
  };

  cargoHash = "sha256-PIuPUs+EgotYml0EQgDJHM4HOIf8eTSGr/DtKENs1cY=";
  useFetchCargoVendor = true;

  # bloats that mcat needs
  buildInputs = with pkgs; [
    ffmpeg
    poppler-utils
  ];

})
