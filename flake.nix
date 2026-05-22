{
  description = "nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix/v2.1.147";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, nur, claude-code-nix, ... }:
  let
    mkDarwinSystem = { profile }: nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit nur claude-code-nix; };
      modules = [
        home-manager.darwinModules.home-manager
        ./darwin-configuration.common.nix
        ./profiles/${profile}/default.nix
      ];
    };
  in
  {
    darwinConfigurations = {
      personal = mkDarwinSystem { profile = "personal"; };
      work = mkDarwinSystem { profile = "work"; };
    };
  };
}
