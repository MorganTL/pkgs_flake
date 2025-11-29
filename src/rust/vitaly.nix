{ pkgs, ... }:
pkgs.rustPlatform.buildRustPackage (finalAttrs: {
  version = "0-unstable-2025-11-28";
  pname = "vitaly";

  src = pkgs.fetchFromGitHub {
    owner = "bskaplou";
    repo = finalAttrs.pname;
    rev = "70c44d5aad9835810dde03a5fec0b7c0bf02634a";
    hash = "sha256-nLughbXh9cW1QrPCTwXbIlUXDgBmbNFxgjdju9ojMQU=";
  };

  cargoHash = "sha256-dJl9JU3k5lnnRyL1IjCpIdgx6KDClWNCed6npez9Yws=";

  # Cargo.lock is missing in the repo, patch it in
  # To get Cargo.lock:
  # 1 `git clone <repo-url>`
  # 2 `nix-shell -p rustup`
  # 3 `rustup update`
  # 4 `cargo build`
  cargoPatches = [
    ./vitaly-add-cargo-lock.patch
  ];

  # bypass E0599, function or associated item not found in `r#macro::Macro`
  # https://github.com/bskaplou/vitaly/blob/406dfd97709d8f586e28351a3fe0c63335cf3251/src/protocol/macro.rs#L627
  # doCheck = false;

  nativeBuildInputs = with pkgs; [
    pkg-config
  ];

  buildInputs = with pkgs; [
    xz # liblzma for rust-lzma
    libudev-zero # libudev for hidapi
  ];
})
