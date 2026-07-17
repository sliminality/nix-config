{
  description = "nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Source pins — no nix interface, just source archives managed via flake.lock.
    fish-pure     = { url = "github:pure-fish/pure/f37bb2898490d0e48661e3cf6a13d5a879135697";              flake = false; };
    nix-env-fish  = { url = "github:lilyball/nix-env.fish/7b65bd228429e852c8fdfa07601159130a818cfa";        flake = false; };
    fasd-fish     = { url = "github:fishgretel/fasd/9a16eddffbec405f06ac206256b0f7e3112b0e2c";             flake = false; };
    rainglow      = { url = "github:sliminality/rainglow-vim/2402956186b8e53355b88043b4c6e50213cb5ede";     flake = false; };
    everforest    = { url = "github:sainnhe/everforest/fa0643b4b76acdaa2c320395575fc86daad7e712";           flake = false; };
    sf-pro-fonts  = { url = "github:sahibjotsaggu/San-Francisco-Pro-Fonts/8bfea09aa6f1139479f80358b2e1e5c6dc991a58"; flake = false; };
    sf-mono-fonts = { url = "github:supercomputra/SF-Mono-Font/1409ae79074d204c284507fef9e479248d5367c1";   flake = false; };
    mlbt          = { url = "github:mlb-rs/mlbt/20019966b1aebd0b1550c37075d7618879bd9461"; # v0.4.0
                      flake = false; };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, nur, claude-code-nix
            , fish-pure, nix-env-fish, fasd-fish, rainglow, everforest
            , sf-pro-fonts, sf-mono-fonts, mlbt, ... }:
  let
    mkDarwinSystem = { profile }: nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit nur claude-code-nix
                             fish-pure nix-env-fish fasd-fish rainglow everforest
                             sf-pro-fonts sf-mono-fonts mlbt; };
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
