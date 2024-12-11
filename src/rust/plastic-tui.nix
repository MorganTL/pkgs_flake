{ pkgs, rustPlatform }:
rustPlatform.buildRustPackage {
  version = "0.1.0";
  pname = "plastic_tui";
  src = pkgs.fetchFromGitHub {
    owner = "Amjad50";
    repo = "plastic";
    rev = "f254082ceb71fa092df890e26e767026819891ce";
    hash = "sha256-YAb4zTQpRigO3FeugX033DnwSVAQ+h5cBED8y3wCmyg=";
  };

  # compile only the `plastic_tui` cargo workspace members 
  # https://discourse.nixos.org/t/using-buildrustcrate-to-build-a-project-within-a-cargo-workspace/15672/8
  buildAndTestSubdir = "plastic_tui";

  buildInputs = with pkgs; [
    alsa-lib
    libgcc
    libudev-zero
  ];

  nativeBuildInputs = with pkgs; [
    pkg-config
    # systemdLibs
    # libinput
  ];

  cargoHash = "sha256-XnH8GM3KBhzuUOhIApW/4BkJr1UzeC6yHnRSNzwU79A=";
}
