{
  description = "flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    naersk.url = "github:nix-community/naersk";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      naersk,
      rust-overlay,
      treefmt-nix,
    }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ (import rust-overlay) ];
      };
      rust = pkgs.rust-bin.stable."1.81.0".default.override {
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

      tetrs = pkgs.callPackage ./src/rust/tetrs-terminal.nix { inherit rustPlatform; };
      tracker = pkgs.callPackage ./src/rust/tracker.nix { inherit rustPlatform; };
      binsider = pkgs.callPackage ./src/rust/binsider.nix { inherit rustPlatform; };
      plastic-tui = pkgs.callPackage ./src/rust/plastic-tui.nix { inherit rustPlatform; };


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

      # from https://github.com/NixOS/nixpkgs/pull/336646
      ffts = pkgs.stdenv.mkDerivation rec {
        pname = "ffts";
        version = "unstable-2019-03-19";

        src = pkgs.fetchFromGitHub {
          owner = "linkotec";
          repo = "ffts";
          rev = "2c8da4877588e288ff4cd550f14bec2dc7bf668c";
          hash = "sha256-Cj0n7fwFAu6+3ojgczL0Unobdx/XzGNFvNVMXdyHXE4=";
        };

        nativeBuildInputs = with pkgs; [
          cmake
          git
        ];
        buildInputs = [ ];

        cmakeFlags = [
          "-DCURRENT_GIT_VERSION=${pkgs.lib.substring 0 7 src.rev}"
          "-DENABLE_SHARED=ON"
          "-Wno-deprecated"
        ];

      };

      scopelhal-apps = pkgs.stdenv.mkDerivation rec {
        pname = "ngscopeclient";
        version = "unstable-master";

        src = pkgs.fetchFromGitHub {
          owner = "ngscopeclient";
          repo = "scopehal-apps";
          rev = "d5cd16777dcdb88603042bbbd44c318bb9a36b44";
          hash = "sha256-QssNo+6vM1qtQSpGn+ciEhDG8PIrNrmqxm/kUb4NODQ=";
          fetchSubmodules = true;
        };

        nativeBuildInputs = with pkgs; [
          cmake
          wrapGAppsNoGuiHook
        ];

        buildInputs = [
          pkgs.pkg-config
          pkgs.libsigcxx
          pkgs.gtkmm3
          pkgs.cairomm
          pkgs.yaml-cpp
          pkgs.catch2
          pkgs.glfw
          pkgs.libtirpc
          pkgs.liblxi
          pkgs.glew
          pkgs.libllvm
          pkgs.libdrm
          pkgs.elfutils
          pkgs.xorg.libxcb
          pkgs.zstd
          pkgs.xorg.libxshmfence
          pkgs.xorg.xcbutilkeysyms
          pkgs.systemd
          pkgs.vulkan-headers
          pkgs.vulkan-loader
          pkgs.vulkan-tools
          pkgs.spirv-tools
          pkgs.glslang
          pkgs.shaderc
          ffts
        ];

        patch = [ ./dslogic_plus.patch ];

        # Targets InitializeSearchPaths
        postPatch = ''
          substituteInPlace lib/scopehal/scopehal.cpp \
            --replace '"/share/' '"/../share/'
        '';

      };

      # from https://github.com/NixOS/nixpkgs/blob/ab70b01c83dd5ba876d8d79ef5cba24ef185c8c9/pkgs/applications/science/electronics/dsview/libsigrok4dsl.nix
      libsigrok4dsl = pkgs.stdenv.mkDerivation {
        pname = "libsigrok4dsl";
        version = "1.12";

        src = pkgs.fetchFromGitHub {
          owner = "DreamSourceLab";
          repo = "DSView";
          rev = "5a9481fd0697d66ce5ce0e46a8d233125e6cb5ac";
          hash = "sha256-4sEseH5OmWsesNj+c+RuAu6Oj4yn8TibaA8MnKLo7h4=";
        };

        postUnpack = ''
          export sourceRoot=$sourceRoot/libsigrok4DSL
        '';

        nativeBuildInputs = with pkgs; [
          pkg-config
          autoreconfHook
        ];

        buildInputs = with pkgs; [
          glib
          libzip
          libserialport
          libusb1
          libftdi
          systemd
          check
          alsa-lib
        ];
      };

      scopehal-sigrok-bridge = pkgs.stdenv.mkDerivation {
        pname = "scopehal-sigrok-bridge";
        version = "0-unstable-2022-05-08";

        src = pkgs.fetchFromGitHub {
          owner = "MorganTL";
          repo = "scopehal-sigrok-bridge";
          rev = "e96ebfb310e022faa94307f10004e7230de7aef1";
          hash = "sha256-YRA7rRAE+HCWo7BV9T0rW/2cw5bdIPYrJMKSKbTCUPE=";
          fetchSubmodules = true;
        };

        nativeBuildInputs = with pkgs; [
          cmake
          pkg-config
          libsigrok4dsl
        ];

        buildInputs = with pkgs; [
          glib
          libserialport
          libusb1
          libzip
          pcre2
        ];

        # see https://github.com/NixOS/nixpkgs/pull/73377/files
        # bypass error: format not a string literal and no format arguments
        hardeningDisable = [ "format" ];

        # No install phase in make file
        installPhase = ''
          mkdir -p $out/bin
          cp scopehal-sigrok-bridge $out/bin
        '';

        postPatch = ''
          substituteInPlace src/main.cpp \
            --replace '"/usr/local/share/DSView/res/' '"${libsigrok4dsl.src}/DSView/res/'
        '';

      };

      scopehal-uhd-bridge = pkgs.stdenv.mkDerivation {
        pname = "scopehal-uhd-bridge";
        version = "0-unstable-2024-01-22";

        src = pkgs.fetchFromGitHub {
          owner = "ngscopeclient";
          repo = "scopehal-uhd-bridge";
          rev = "e9ab04cd5f17743c42b2c4be31754efc122bb3cd";
          hash = "sha256-m6ederJ2hx0M/iIqon4NMjvOQn03wdtF0wZyTlPylpE=";
          # hash = pkgs.lib.fakeHash;
          fetchSubmodules = true;
        };

        nativeBuildInputs = with pkgs; [
          cmake
          pkg-config
          uhd
          boost
        ];

        # see https://github.com/NixOS/nixpkgs/pull/73377/files
        # bypass error: format not a string literal and no format arguments
        hardeningDisable = [ "format" ];

        # NOTE: use  "cp * $out" to check where is the executable
        # No install phase in make file
        installPhase = ''
          mkdir -p $out/bin
          cp src/uhdbridge/uhdbridge $out/bin
        '';
      };
    in
    {
      formatter.x86_64-linux = treefmt-nix.lib.mkWrapper nixpkgs.legacyPackages.x86_64-linux {
        projectRootFile = "flake.nix";
        # see for more options https://flake.parts/options/treefmt-nix
        programs.nixfmt.enable = true;
      };

      packages.x86_64-linux = {
        tetrs = tetrs;
        binsider = binsider;
        confetty = confetty;
        tracker = tracker;
        plastic-tui = plastic-tui;
        fireplace = fireplace;
        lifecycler = lifecycler;
        scopehal-apps = scopelhal-apps;
        scopehal-sigrok-bridge = scopehal-sigrok-bridge;
        scopehal-uhd-bridge = scopehal-uhd-bridge;
      };
    };
}
