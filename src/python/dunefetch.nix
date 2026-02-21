{ pkgs, ... }:
pkgs.python3Packages.buildPythonPackage {
  pname = "dunefetch";
  version = "0-unstable-2025-7-16";
  pyproject = true;

  src = pkgs.fetchFromGitHub {
    owner = "datavorous";
    repo = "dunefetch";
    rev = "7f20d7ae89e0fbc3052d82a45f11eab4e2640091";
    hash = "sha256-T8hjTbrfO7ai31eBSgV+rOjw3gFcATa+2PnDzHHkSNk=";
  };

  buildInputs = with pkgs.python3Packages; [
    build
    setuptools
    # wheel
  ];

  propagatedBuildInputs = with pkgs.python3Packages; [
    psutil
  ];
}
