{ pkgs, rustPlatform }:
rustPlatform.buildRustPackage {
  version = "0.1.1";
  pname = "tracker";
  src = pkgs.fetchFromGitHub {
    owner = "ShenMian";
    repo = "tracker";
    rev = "1c6b3b475af050da0cf0ac03e83487781b88213c";
    hash = "sha256-w18zQ/OG1CeQQEW2e6pkHkYjTnaTWWOjPcaDJ//mAAg=";
  };

  cargoHash = "sha256-IoDzrW6JMmU0MeD5rXAhiHw1Nf0d2pHiIucsRk3raao=";
}
