{ pkgs, rustPlatform }:
rustPlatform.buildRustPackage (finalAttr: {
  version = "0.1.2";

  pname = "ftdv";

  src = pkgs.fetchFromGitHub {
    owner = "wtnqk";
    repo = "ftdv";
    rev = "v${finalAttr.version}";
    hash = "sha256-J1lWrfZeH/V1hckLGWDoeU6aKFoLimddzaTKMQ8sDs8=";
  };

  cargoHash = "sha256-ZFIlDwq0qmBfL/GL7fMetUWuUhq6ywDt060dyoSCFqA=";
  useFetchCargoVendor = true;
})
