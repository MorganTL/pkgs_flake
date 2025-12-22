{ pkgs, ... }:
pkgs.rustPlatform.buildRustPackage (finalAttrs: {
  version = "0.1.14";
  pname = "vitaly";

  src = pkgs.fetchFromGitHub {
    owner = "bskaplou";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-hJHtJG0tn5Xxs6MPIdEGjLya2o4rAESWymS//jc29WE=";
  };

  cargoHash = "sha256-POel9D5ZXxd9bPkHFnTefwl8767tfuYl9hm0w6E/VC8=";

  nativeBuildInputs = with pkgs; [
    pkg-config
  ];

  buildInputs = with pkgs; [
    xz # liblzma for rust-lzma
    libudev-zero # libudev for hidapi
  ];
})
