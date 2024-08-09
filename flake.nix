{
  description = "flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    naersk.url = "github:nix-community/naersk";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      naersk,
      rust-overlay,
    }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ (import rust-overlay) ];
      };
      rust = pkgs.rust-bin.stable."1.80.0".default.override {
        extensions = [ "rust-src" ];
        targets = [ ];
      };
      rustPlatform = pkgs.makeRustPlatform {
        rustc = rust;
        cargo = rust;
      };
      nsk = pkgs.callPackage naersk {
        cargo = rust;
        rustc = rust;
      };

      # RUST pkgs
      tetrs = rustPlatform.buildRustPackage {
        version = "0.1.0";
        pname = "tetrs_terminal";
        src = pkgs.fetchFromGitHub {
          owner = "Strophox";
          repo = "tetrs";
          rev = "93dc5f6700d32c6d948428a4f6d86c97e33a9764";
          hash = "sha256-lv39ftC6RuYdbMHsiZPMST9Ewtl7lwHl0qAn8VqmoWk=";
        };

        cargoHash = "sha256-qCf646DGOEJ8xMxxUaBB1L8pEUalsHy5YznYWODqpiY= ";

        cargoPatches = [
          # a patch file to add/update Cargo.lock in the source code
          ./tetrs-add-cargo-lock.patch
        ];
      };

      confetty = rustPlatform.buildRustPackage {
        version = "0.1.0";
        pname = "confetty_rs";
        src = pkgs.fetchFromGitHub {
          owner = "Handfish";
          repo = "confetty_rs";
          rev = "2012f53672b08d96c1f14aab90e19011bb78a888";
          hash = "sha256-3UGKD/niuqaZ1CxWKAF4RH6v9uJ+ckweIclwobV2EN8=";
        };

        cargoHash = "sha256-zd9iJxYtBUo10S3yej4Xm8mS7mbiym9G953vF1nVMEM=";
      };

      lifecycler = nsk.buildPackage {
        # one of the dependencies of lifecycler doens't have Cargo.lock file
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
      };

      # C/C++ pkgs
      fireplace = pkgs.stdenv.mkDerivation {
        pname = "fireplace";
        version = "0.0.0";

        src = pkgs.fetchFromGitHub {
          owner = "Wyatt915";
          repo = "fireplace";
          rev = "aa2070b73be9fb177007fc967b066d88a37e3408";
          hash = "sha256-2NUE/zaFoGwkZxgvVCYXxToiL23aVUFwFNlQzEq9GEc=";
        };

        nativeBuildInputs = with pkgs; [ ncurses ];
        installFlags = [ "DESTDIR=$(out)/bin" ];
      };
    in
    {
      packages.x86_64-linux = {
        tetrs = tetrs;
        confetty = confetty;
        fireplace = fireplace;
        lifecycler = lifecycler;
      };
    };
}
