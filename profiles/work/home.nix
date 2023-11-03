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

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      github.copilot
      esbenp.prettier-vscode
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "ayu";
        publisher = "teabyii";
        version = "1.0.5";
        sha256 = "sha256-+IFqgWliKr+qjBLmQlzF44XNbN7Br5a119v9WAnZOu4=";
      }
      {
        name = "copilot-chat";
        publisher = "GitHub";
        version = "0.9.2023101202";
        sha256 = "sha256-DZnWNwmpNWHYMR3ycGyidyOPWSeJ0OMRFbjjnFj4oNo=";
      }
    ];
    userSettings = {
      workbench.colorTheme = "Ayu Mirage Bordered";
      github.copilot = {
        inlineSuggest.enable = false;
        enable = {
          "*" = true;
          yaml = false;
          plaintext = false;
          markdown = false;
        };
      };
    };
  };
}
