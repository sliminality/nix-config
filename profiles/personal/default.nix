# Top-level nix-darwin configuration for my personal machine.

{ config, pkgs, lib, ... }:

{
  imports = [
    ../../darwin-configuration.common.nix
  ];

  networking.computerName = "schelemeus";

  system.defaults = {
    NSGlobalDomain.AppleICUForce24HourTime = true; 

    # Set default dock items.
    dock.persistent-apps = [
      "/Applications/Beeper Desktop 2.app"
      "/Applications/Discord.app"
      "/Applications/Firefox.app"
      "${pkgs.alacritty}/Applications/Alacritty.app"
      "/Applications/Notion.app"
      "/Users/slim/Applications/MLB.TV.app"
    ];
  };

  homebrew.taps = [
    "sliminality/1password6"
  ];

  homebrew.casks = [
    "1password6"
    "automattic-texts"
    "beeper"
    "discord"
    "google-chrome"
    "notion"
    "parallels@17"
    "slack"
    "steam"
    "the-unarchiver"
    "tunnelbear"
    "vlc"
    "zoom"
  ];

  homebrew.masApps = {
    bear = 1091189122;
    goodnotes = 1444383602;
    nextdns = 1464122853;
    # genki = 1555925018;
    # ms-powerpoint = 462062816; 
    # ms-word = 462054704;
  };
  
  home-manager.users.slim = import ./home.nix;
}
