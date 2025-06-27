{ pkgs, ... }:
# from https://github.com/NixOS/nixpkgs/pull/336646
pkgs.stdenv.mkDerivation rec {
  pname = "ngscopeclient";
  version = "0-unstable-2025-04-14";

  src = pkgs.fetchFromGitHub {
    owner = "ngscopeclient";
    repo = "scopehal-apps";
    rev = "9f2d72b60200b4e67873c430a478dd9acc1fc84f";
    hash = "sha256-6IYup6odSkKHofQi+U/pqAOuXMR1ykwKBtpjRjj3p08=";
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

  # Force XWayland to bypass window scaling issue
  # see https://github.com/ngscopeclient/scopehal-apps/issues/824
  postInstall = ''
    wrapProgram $out/bin/${pname} --set XDG_SESSION_TYPE x11
  '';
}
