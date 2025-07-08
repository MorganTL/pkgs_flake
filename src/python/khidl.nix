{ pkgs, ... }:
pkgs.python3Packages.buildPythonPackage rec {
  pname = "khidl";
  version = "1.2.4";
  pyproject = true;

  src = pkgs.fetchFromGitHub {
    owner = "qwerinope";
    repo = "khidl";
    rev = "v${version}";
    hash = "sha256-mLCT4fzzKkKHtSTKs/QRaUq5hMbWdim2psYgsLbPzYc=";
  };

  buildInputs = with pkgs.python3Packages; [
    build
    setuptools
    wheel
  ];

  propagatedBuildInputs = with pkgs.python3Packages; [
    beautifulsoup4
    jsonschema
    prettytable
    requests
    tqdm
  ];
}
