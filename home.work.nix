# Home Manager configuration for my work machine.

{ config, pkgs, lib, ... }:

{
  imports = [
    ./home.nix
  ];

  programs.git = {
    userEmail = "slim@makenotion.com";
    userName = "Slim Lim";
  };
}
