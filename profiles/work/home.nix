# Home Manager configuration for my work machine.
# Anything that shouldn't go on every fresh install goes here.

{ config, pkgs, lib, ... }:

{
  imports = [
    ../../home.common.nix
  ];

  programs.git = {
    userEmail = "slim@makenotion.com";
    userName = "Slim Lim";
  };
}
