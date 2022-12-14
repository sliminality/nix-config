# Top-level nix-darwin configuration for my work machine.

{ config, pkgs, lib, ... }:

{
  imports = [
    ../../darwin-configuration.common.nix
  ];

  homebrew.casks = [
    "caffeine"
    "postico"
    "postman"
  ];
  
  home-manager.users.slim = import ./home.nix;
}
