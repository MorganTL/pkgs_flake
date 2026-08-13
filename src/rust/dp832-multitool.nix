{ pkgs, ... }:
pkgs.rustPlatform.buildRustPackage {
  version = "0-unstable-2025-12-20";
  pname = "remote-control";

  src = pkgs.fetchFromGitHub {
    owner = "marcusfolkesson";
    repo = "dp832-multitool";
    rev = "f91441eb4cff4346e4687f467736f9e1b0d16a90";
    hash = "sha256-OW559imUCKOABZohr8hW0Zr6QHjpn9jza3XyBF0l+sw=";
  };

  # Cargo.lock is missing in the repo, patch it in
  # To get Cargo.lock:
  # 1 `git clone <repo-url>`
  # 2 `nix-shell -p rustup`
  # 3 `rustup update`
  # 4 `cargo build`
  postPatch = ''
    ln -s ${./dp832-multitool-Cargo.lock} Cargo.lock
  '';

  # get cargohash from Cargo.lock file directly
  cargoLock.lockFile = ./dp832-multitool-Cargo.lock;
}
