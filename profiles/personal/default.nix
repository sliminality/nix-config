# Top-level nix-darwin configuration for my personal machine.

{ config, pkgs, lib, ... }:

{
  imports = [
    ../../darwin-configuration.common.nix
  ];

  networking.computerName = "megaera";

  # TODO: PR into nix-darwin.
  system.defaults.NSGlobalDomain.AppleICUForce24HourTime = true; 

  homebrew.casks = [
    "1password6"
    "discord"
    "google-chrome"
    "notion"
    "papers3"
    "parallels17"
    "slack"
    "steam"
    "the-unarchiver"
    "vlc"
    "zoom"
  ];

  homebrew.masApps = {
    goodnotes = 1444383602;
    # genki = 1555925018;
    # ms-powerpoint = 462062816; 
    # ms-word = 462054704;
  };
  
  home-manager.users.slim = import ./home.nix;
}
