{ pkgs, rustPlatform }:
rustPlatform.buildRustPackage {
  version = "0.8.28";
  pname = "angryoxide";
  src =
    (pkgs.fetchFromGitHub {
      owner = "Ragnt";
      repo = "AngryOxide";
      rev = "02bac49d7f16f8891e243645b3c6f205d70acb34";
      hash = "sha256-wzDDsBbx1i2N+cvs+Lj80CY/Vciwov1CeOXXgIVybIo=";
      fetchSubmodules = true;
    }).overrideAttrs
      (_: {
        # the repo use ssh instead of http url which is not supported by fetchFromGithub
        # from https://github.com/NixOS/nixpkgs/issues/195117#issuecomment-1410398050
        GIT_CONFIG_COUNT = 1;
        GIT_CONFIG_KEY_0 = "url.https://github.com/.insteadOf";
        GIT_CONFIG_VALUE_0 = "git@github.com:";
      });

  cargoHash = "sha256-/XCEDYavIlAiZ0uveCS4h67o4y1jnmBCsBFq8eHf3bE=";
}
