{ pkgs, ... }:
pkgs.python3Packages.buildPythonPackage rec {
  pname = "khinsider";
  version = "0.0.0";
  pyproject = false; # the repo don't use setup.py
  src = pkgs.fetchFromGitHub {
    owner = "obskyr";
    repo = "khinsider";
    rev = "bd7ef673ec7af5ce8f580df8f7a3f0746ff1a1ad";
    sha256 = "sha256-T3mRTWNjaH0dVxQ2SNr4Xw4PdjLfd3Bp0IsqEGjuS3g=";
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
