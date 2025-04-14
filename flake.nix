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
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
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
      git-hooks,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
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
      rustdir = ./src/rust;
      tetrs = pkgs.callPackage "${rustdir}/tetrs-terminal.nix" { inherit rustPlatform; };
      confetty = pkgs.callPackage "${rustdir}/confetty-rs.nix" { inherit rustPlatform; };
      tracker = pkgs.callPackage "${rustdir}/tracker.nix" { inherit rustPlatform; };
      binsider = pkgs.callPackage "${rustdir}/binsider.nix" { inherit rustPlatform; };
      plastic-tui = pkgs.callPackage "${rustdir}/plastic-tui.nix" { inherit rustPlatform; };
      lifecycler = pkgs.callPackage "${rustdir}/lifecycler.nix" { inherit nsk; };
      angry-oxide = pkgs.callPackage "${rustdir}/angry-oxide.nix" { inherit rustPlatform; };

      # Python pkgs
      pythondir = ./src/python;
      khinsider = pkgs.callPackage "${pythondir}/khinsider.nix" { };

      # Godot pkgs
      godotdir = ./src/godot;
      age-of-war = pkgs.callPackage "${godotdir}/age-of-war.nix" { };

      # C/C++ pkgs
      cppdir = ./src/cpp;
      rf2dfieldsolver = pkgs.qt6Packages.callPackage "${cppdir}/rf2dfieldsolver.nix" { };

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
      scopehal-apps = pkgs.stdenv.mkDerivation {
        pname = "ngscopeclient";
        version = "0-unstable-2025-04-14";

        src = pkgs.fetchFromGitHub {
          owner = "ngscopeclient";
          repo = "scopehal-apps";
          rev = "9f2d72b60200b4e67873c430a478dd9acc1fc84f";
          hash = "sha256-6IYup6odSkKHofQi+U/pqAOuXMR1ykwKBtpjRjj3p08=";
          fetchSubmodules = true;
        };

        nativeBuildInputs = with pkgs; [
          cmake
          wrapGAppsNoGuiHook
        ];

        buildInputs = with pkgs; [
          cairomm
          catch2
          elfutils
          ffts
          glew
          glfw
          glslang
          gtkmm3
          libdrm
          libllvm
          liblxi
          libsigcxx
          libtirpc
          hidapi
          pkg-config
          shaderc
          spirv-tools
          systemd
          vulkan-headers
          vulkan-loader
          vulkan-tools
          xorg.libxcb
          xorg.libxshmfence
          xorg.xcbutilkeysyms
          yaml-cpp
          zstd
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
      checks.${system}.default = git-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          deadnix.enable = true;
          nixfmt-rfc-style.enable = true;
          statix = {
            enable = true;
            settings.config = "./statix.toml";
            settings.format = "stderr";
          };
          typos.enable = true;
        };
      };
      formatter.${system} = treefmt-nix.lib.mkWrapper nixpkgs.legacyPackages.x86_64-linux {
        projectRootFile = "flake.nix";
        # see for more options https://flake.parts/options/treefmt-nix
        programs.nixfmt.enable = true;
      };
      devShells.${system}.default = pkgs.mkShell {
        name = "nixos-system";
        shellHook = ''
          ${self.checks.${system}.default.shellHook}
        '';
        packages = [
          self.checks.${system}.default.enabledPackages
          khinsider
        ];
      };

      packages.x86_64-linux = {
        # RUST pkgs
        inherit
          angry-oxide
          binsider
          confetty
          lifecycler
          plastic-tui
          tetrs
          tracker
          ;
        # Python pkgs
        inherit khinsider;
        # Godot pgks
        inherit age-of-war;
        # C/C++ pkgs
        inherit
          rf2dfieldsolver
          fireplace
          scopehal-sigrok-bridge
          scopehal-uhd-bridge
          scopehal-apps
          ;
      };
    };
}
