{ pkgs, ... }:
let
  version = "0.1";
in
pkgs.scopehal-apps.overrideAttrs (oldAttr: {
  inherit version;
  src = pkgs.fetchFromGitHub {
    owner = "ngscopeclient";
    repo = "scopehal-apps";
    rev = "v${version}";
    hash = "sha256-AfO6JaWA9ECMI6FkMg/LaAG4QMeZmG9VxHiw0dSJYNM=";
    fetchSubmodules = true;
  };

  patches = oldAttr.patches or [ ] ++ [ ./dslogic_plus.patch ];
})
