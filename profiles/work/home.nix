# Home Manager configuration for my work machine.
# Anything that shouldn't go on every fresh install goes here.

{ config, pkgs, lib, ... }:

{
  imports = [
    ../../home.common.nix
  ];

  home.packages = with pkgs; [
    (import ../../darwin-modules/apps/notion-dev.nix { inherit lib stdenv pkgs; })
  ];

  programs.git = {
    userEmail = "slim@makenotion.com";
    userName = "Slim Lim";
  };
}
