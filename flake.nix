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
      fireplace = pkgs.callPackage "${cppdir}/fireplace.nix" { };
      scopehal-apps = pkgs.callPackage "${cppdir}/scopehal_apps.nix" { };
      scopehal-sigrok-bridge = pkgs.callPackage "${cppdir}/scopehal_sigrok_bridge.nix" { };
      skindeep = pkgs.callPackage "${cppdir}/skindeep.nix" { }; # requires game assets

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
          fireplace
          rf2dfieldsolver
          scopehal-apps
          scopehal-sigrok-bridge
          scopehal-uhd-bridge
          skindeep
          ;
      };
    };
}
