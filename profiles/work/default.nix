# Top-level nix-darwin configuration for my work machine.

{ config, pkgs, lib, ... }:

{
  imports = [
    ../../darwin-configuration.common.nix
  ];

  networking.computerName = "thanatos";

  homebrew.casks = [
    "cursor"
    "caffeine"
    "docker"
    "parallels"
    "postico"
    "postman"
    "steam"
  ];
  
  home-manager.users.slim = import ./home.nix;
}
