{ pkgs, ... }:
pkgs.python3Packages.buildPythonPackage rec {
  pname = "khinsider";
  version = "0.0.0";
  pyproject = false; # the repo don't use setup.py

  src = pkgs.fetchFromGitHub {
    owner = "IhavenoideawhatIamdoingIamadog";
    repo = "khinsider";
    rev = "2abecf911a655ad70230706167fd8b2f97f5be7f";
    hash = "sha256-ws+YmZoAG0pjHcmkyuGy2f0A3ThHwdO8FaJB6dZUP3o=";
  };

  propagatedBuildInputs = with pkgs; [
    python3Packages.requests
    python3Packages.beautifulsoup4
  ];
  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 $src/${pname}.py $out/bin/${pname}
  '';
}
