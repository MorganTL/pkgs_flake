{ pkgs, rustPlatform }:
rustPlatform.buildRustPackage {
  version = "0.1.0";
  pname = "confetty_rs";
  src = pkgs.fetchFromGitHub {
    owner = "Handfish";
    repo = "confetty_rs";
    rev = "2012f53672b08d96c1f14aab90e19011bb78a888";
    hash = "sha256-3UGKD/niuqaZ1CxWKAF4RH6v9uJ+ckweIclwobV2EN8=";
  };

  cargoHash = "sha256-Rn7vAgryvJ3gn4WR9hhEJhMyiaxiHobfxFNblhs11Ow=";
}
