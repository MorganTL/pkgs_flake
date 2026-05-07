{ pkgs, ... }:
let
  version = "1.3.9";
in
pkgs.pulse-visualizer.overrideAttrs (oldAttr: {
  inherit version;
  src = pkgs.fetchFromGitHub {
    owner = "Audio-Solutions";
    repo = "pulse-visualizer";
    tag = "v${version}";
    hash = "sha256-IzJXFbsbpRszJEpU98exK4EKGU8kHH51BZzokJwzPzU=";
  };
  buildInputs =
    oldAttr.buildInputs
    # new dependencies of v1.3.9
    # remove when nixpkg updates
    ++ (with pkgs; [
      sdl3-image
      curl
    ]);
})
