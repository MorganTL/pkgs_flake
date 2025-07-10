{ pkgs }:
pkgs.rustPlatform.buildRustPackage (finalAttrs: {
  version = "tattoy-v0.1.6";
  pname = "tattoy";

  src = pkgs.fetchFromGitHub {
    owner = "tattoy-org";
    repo = "tattoy";
    rev = finalAttrs.version;
    hash = "sha256-PIgrs1YiLk8RAKjySTrFHT2dWUcxDbAviXNKTyo7ljs=";
  };

  # bypass https://github.com/tattoy-org/tattoy/pull/104#issuecomment-3045996096
  doCheck = false;
  cargoHash = "sha256-871Eehi10lcOmpSUeuvqeuOAbk/ryX3jXhdP5WC+/Rc=";
  useFetchCargoVendor = true;

  nativeBuildInputs = with pkgs; [
    pkg-config
  ];

  buildInputs = with pkgs; [
    dbus
    xorg.libxcb
  ];

})
