{ pkgs, ... }:
pkgs.python312Packages.buildPythonPackage rec {
  pname = "pyfdax";
  version = "0.9.4";
  pyproject = true;

  src = pkgs.fetchFromGitHub {
    owner = "chipmuenk";
    repo = "pyfda";
    rev = "v${version}";
    hash = "sha256-75aiOoxP4ykVkPZXgkkHtMbDfdmlSDoQR8gka4/474o=";
  };

  buildInputs = with pkgs; [
    qt5.qtbase
    qt5.qtwayland
    python312Packages.setuptools
  ];

  nativeBuildInputs = [ pkgs.qt5.wrapQtAppsHook ];
  dontWrapQtApps = true;
  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  # upstream use numpy 1.x with newer scipy which use numpy 2.x
  # ignore duplicate dependencies check
  catchConflicts = false;

  propagatedBuildInputs = with pkgs.python312Packages; [
    numpy_1
    scipy
    matplotlib
    pyqt5
    docutils
    mplcursors
    numexpr
    markdown
    amaranth
  ];
}
