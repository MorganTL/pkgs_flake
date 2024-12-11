{ pkgs, rustPlatform }:
rustPlatform.buildRustPackage {
  version = "0.1.0";
  pname = "binsider";
  src = pkgs.fetchFromGitHub {
    owner = "orhun";
    repo = "binsider";
    rev = "7e0dbbb9615566ce75327bce1416e992784faaad";
    hash = "sha256-+QgbSpiDKPTVdSm0teEab1O6OJZKEDpC2ZIZ728e69Y=";
  };

  checkFlags = [
    # both tests are reading the directoy name which is not accessible
    "--skip=app::tests::test_extract_strings"
    "--skip=app::tests::test_init"
  ];

  cargoHash = "sha256-lXYTZ3nvLrfEgo7AY/qSQYpXsyrdJuQQw43xREezNn0=";
}
