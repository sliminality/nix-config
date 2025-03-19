# Top-level nix-darwin configuration for my work machine.

{ config, pkgs, lib, ... }:

{
  imports = [
    ../../darwin-configuration.common.nix
  ];

  networking.computerName = "thanatos";

  system.defaults.dock = {
    # Set default dock items.
    persistent-apps = [
      "/Applications/Slack.app"
      "/Applications/Firefox.app"
      "${pkgs.alacritty}/Applications/Alacritty.app"
      "/Applications/Notion Dev.app"
      "/Applications/Notion.app"
    ];
  };

  homebrew.casks = [
    "cursor"
    "caffeine"
    "docker"
    "postico"
    "postman"
    "steam"
  ];
  
  home-manager.users.slim = import ./home.nix;
}
