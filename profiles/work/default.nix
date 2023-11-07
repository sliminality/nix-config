# Top-level nix-darwin configuration for my work machine.

{ config, pkgs, lib, ... }:

{
  imports = [
    ../../darwin-configuration.common.nix
  ];

  networking.computerName = "thanatos";

  homebrew.casks = [
    "caffeine"
    "docker"
    "openvpn-connect"
    "parallels"
    "postico"
    "postman"
    "steam"
  ];
  
  home-manager.users.slim = import ./home.nix;
}
