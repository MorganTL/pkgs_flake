{ pkgs, ... }:
# from https://github.com/NixOS/nixpkgs/pull/336646
pkgs.stdenv.mkDerivation (finalAttr: {
  pname = "ngscopeclient";
  version = "0.1";

  src = pkgs.fetchFromGitHub {
    owner = "ngscopeclient";
    repo = "scopehal-apps";
    rev = "v${finalAttr.version}";
    hash = "sha256-AfO6JaWA9ECMI6FkMg/LaAG4QMeZmG9VxHiw0dSJYNM=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = with pkgs; [
    cmake
    wrapGAppsNoGuiHook
  ];

  buildInputs = with pkgs; [
    cairomm
    catch2
    elfutils
    ffts
    glew
    glfw
    glslang
    gtkmm3
    libdrm
    libllvm
    liblxi
    libsigcxx
    libtirpc
    hidapi
    pkg-config
    shaderc
    spirv-tools
    systemd
    vulkan-headers
    vulkan-loader
    vulkan-tools
    xorg.libxcb
    xorg.libxshmfence
    xorg.xcbutilkeysyms
    yaml-cpp
    zstd
  ];

  patch = [ ./dslogic_plus.patch ];

  # Targets InitializeSearchPaths
  postPatch = ''
    substituteInPlace lib/scopehal/scopehal.cpp \
      --replace '"/share/' '"/../share/'
  '';
})
