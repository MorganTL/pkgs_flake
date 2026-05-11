{ pkgs, lib, ... }:
let
  libPath = lib.makeLibraryPath (
    with pkgs;
    [
      libxkbcommon
      vulkan-loader
    ]
  );
in
pkgs.rustPlatform.buildRustPackage (finalAttrs: {
  version = "0.2.0";
  pname = "ratty";

  src = pkgs.fetchFromGitHub {
    owner = "orhun";
    repo = "ratty";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fDNlyTOhwI1nzNf2/Z9DWtTEdJCZEDogLu13ETbpJAw=";
  };

  cargoHash = "sha256-4oLBONIyC924UGTw0d9RzGvNBolWdLMzzC+mihcD3B0=";

  nativeBuildInputs = with pkgs; [
    makeWrapper
    pkg-config
  ];

  buildInputs = with pkgs; [
    # From arch official PKGBUILD
    # https://gitlab.archlinux.org/archlinux/packaging/packages/ratty/-/blob/main/PKGBUILD?ref_type=heads
    fontconfig
    glibc
    libx11
    libxcb
    wayland
    zlib
    # extra lib for bevy (game engine that ratty used)
    # https://discourse.nixos.org/t/help-building-rust-bevy-example-games/74900/2
    libudev-zero
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
    libxkbcommon
  ];

  # fix `Failed loading `libxkbcommon.so.0` errors`
  postInstall = ''
    wrapProgram $out/bin/${finalAttrs.pname} --prefix "LD_LIBRARY_PATH" : "${libPath}"
  '';

})
