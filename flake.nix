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
      rust = pkgs.rust-bin.stable."1.85.0".default.override {
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
      ftdv = pkgs.callPackage "${rustdir}/ftdv.nix" { inherit rustPlatform; };
      tattoy = pkgs.callPackage "${rustdir}/tattoy.nix" { };
      mcat = pkgs.callPackage "${rustdir}/mcat.nix" { };

      # Python pkgs
      pythondir = ./src/python;
      khidl = pkgs.callPackage "${pythondir}/khidl.nix" { };
      khinsider = pkgs.callPackage "${pythondir}/khinsider.nix" { };
      dunefetch = pkgs.callPackage "${pythondir}/dunefetch.nix" { };

      # Godot pkgs
      godotdir = ./src/godot;
      age-of-war = pkgs.callPackage "${godotdir}/age-of-war.nix" { };

      # C/C++ pkgs
      cppdir = ./src/cpp;
      rf2dfieldsolver = pkgs.qt6Packages.callPackage "${cppdir}/rf2dfieldsolver.nix" { };
      fireplace = pkgs.callPackage "${cppdir}/fireplace.nix" { };
      scopehal-apps = pkgs.callPackage "${cppdir}/scopehal_apps.nix" { };
      scopehal-sigrok-bridge = pkgs.callPackage "${cppdir}/scopehal_sigrok_bridge.nix" { };
      scopehal-uhd-bridge = pkgs.callPackage "${cppdir}/scopehal_uhd_bridge.nix" { };
      skindeep = pkgs.callPackage "${cppdir}/skindeep.nix" { }; # requires game assets
      c47 = pkgs.callPackage "${cppdir}/c47.nix" { };
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
          ftdv
          lifecycler
          mcat
          plastic-tui
          tattoy
          tetrs
          tracker
          ;
        # Python pkgs
        inherit
          dunefetch
          khidl
          khinsider
          ;
        # Godot pgks
        inherit age-of-war;
        # C/C++ pkgs
        inherit
          c47
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
