# Home Manager configuration for my work machine.
# Anything that shouldn't go on every fresh install goes here.

{ config, pkgs, lib, ... }:

{
  imports = [
    ../../home.common.nix
  ];

  home.packages = with pkgs; [
    # (import ../../darwin-modules/apps/notion-dev.nix { inherit lib stdenv pkgs; })
    # (import ../../darwin-modules/apps/n.nix { inherit lib stdenv pkgs; })
  ];

  home.sessionVariables = {
    NOTION_NO_PRECOMMIT = true;
    NOTION_NO_PREPUSH = true;
  };

  home.sessionPath = [
    "$HOME/git/notion-next/src/cli"
  ];

  programs.git = {
    userEmail = "slim@makenotion.com";
    userName = "Slim Lim";

    extraConfig = {
      rerere.enabled = true;
    };
  };

  programs.firefox.extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    onepassword-password-manager
  ];
}
