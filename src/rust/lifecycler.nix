{ pkgs, nsk }:
nsk.buildPackage {
  # one of the dependencies of lifecycler doesn't have Cargo.lock file
  # naersk is one of the builder that directly download dependencies binary from cargo.io 
  # Thus, bypassing the missing Cargo.lock problem
  src = pkgs.fetchFromGitHub {
    owner = "cxreiff";
    repo = "lifecycler";
    rev = "992413a7fb79031149db67fb91c35d5a0a94540e";
    hash = "sha256-tonM2xTCAB3BviXeA/4zNJUw2JoHtKKUpQT/q427gBc=";
  };

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    alsa-lib
    pkg-config
    systemdLibs
    libinput
    wayland
    wayland-protocols
  ];

  # winit(egui) is having trouble running on nixos without libGL & libxkbcommon on LD_LIBRARY_APTH
  # see https://github.com/rust-windowing/winit/issues/493
  # lib list: https://github.com/emilk/egui/discussions/1587#discussioncomment-2698470
  # use autoPatchelfHook, but lifecycler cannot find libs in buildInputs
  # https://nixos.org/manual/nixpkgs/stable/#setup-hook-autopatchelfhook
  runtimeDependencies = with pkgs; [
    libGL
    libxkbcommon
  ];
}
