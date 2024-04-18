{
  description = "nix-darwin and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin = {
      # url = "github:lnl7/nix-darwin";
      url = "github:wegank/nix-darwin/mddoc-remove";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      # url = "github:nix-community/home-manager";
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, darwin, home-manager, nur, ... }:
  let 
    system = "aarch64-darwin";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    darwinConfigurations."thanatos" = darwin.lib.darwinSystem {
      inherit system;
      modules = [
        ./profiles/work/default.nix
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.slim = import ./profiles/work/home.nix;
          nixpkgs.overlays = [ nur.overlay ];
        }
      ];
    };
  };
}
