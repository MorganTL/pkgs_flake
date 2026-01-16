{ pkgs, ... }:
pkgs.python3Packages.buildPythonPackage rec {
  pname = "khinsider";
  version = "0.0.0";
  pyproject = false; # the repo don't use setup.py

  # Using fork instead of obskyr repo due to obskyr not merging the PR
  src = pkgs.fetchFromGitHub {
    owner = "checkerberry";
    repo = "khinsider";
    rev = "f84c14be25d1ed8de7f88892990397e1ec6e376f";
    hash = "sha256-ff9S5+Pl9wjnaxx4uCa65LcGCgvgh2ekQtRDgP0TrvE=";
  };

  propagatedBuildInputs = with pkgs; [
    python3Packages.requests
    python3Packages.beautifulsoup4
  ];
  installPhase = ''
    mkdir -p $out/bin
    # install the patches script instead of $src one
    install -Dm755 ./${pname}.py $out/bin/${pname}
  '';
}
