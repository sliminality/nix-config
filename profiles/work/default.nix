# Top-level nix-darwin configuration for my work machine.

{ config, pkgs, lib, ... }:

{
  imports = [
    ../../darwin-configuration.common.nix
  ];

  networking.hostName = "thanatos";

  homebrew.casks = [
    "caffeine"
    "docker"
    "openvpn-connect"
    "postico"
    "postman"
  ];
  
  home-manager.users.slim = import ./home.nix;
}
