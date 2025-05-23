{
  pkgs,
  qt6,
  qmake,
  wrapQtAppsHook,
}:
pkgs.stdenv.mkDerivation rec {
  pname = "RF2DFieldSolver";
  version = "0.0.0";

  src = pkgs.fetchFromGitHub {
    owner = "jankae";
    repo = "RF2DFieldSolver";
    rev = "1f3a9538a64daafea57c74f6bb085918d10cfeeb";
    hash = "sha256-u1sBlgQjgio/QvwVfwNCxmyFqY8sURZ9zRcWfwC49wQ";
  };
  sourceRoot = "${src.name}/Software/RF2DFieldSolver";

  nativeBuildInputs = [
    qmake
    wrapQtAppsHook
  ];
  buildInputs = [
    qt6.full
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp ./RF2DFieldSolver $out/bin
  '';
}
