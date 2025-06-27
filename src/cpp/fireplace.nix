{ pkgs, ... }:
pkgs.stdenv.mkDerivation {
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
}
