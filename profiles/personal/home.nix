# Home Manager configuration for my personal machine.
# Anything that shouldn't go on every fresh install goes here.

{ config, pkgs, lib, ... }:

{
  imports = [
    ../../home.common.nix
  ];

  # TODO: What is the difference between this and packageOverrides?
  # nixpkgs.overlays = let ghcVersion = "8107"; in [
  #   # Override ormolu to allow haskell-language-server to install.
  #   # https://gist.github.com/Gabriel439/b542f6e171f17d5f77a844d848278e14
  #   (pkgsNew: pkgsOld: {
  #     haskell-language-server = pkgsOld.haskell-language-server.override {
  #       supportedGhcVersions = [ ghcVersion ];
  #     };

  #     # https://github.com/nmattia/niv/issues/332#issuecomment-958449218
  #     niv = pkgsNew.haskell.lib.compose.overrideCabal
  #       (drv: { enableSeparateBinOutput = false; })
  #       pkgsOld.haskellPackages.niv;

  #     haskell = pkgsOld.haskell // {
  #       packages = pkgsOld.haskell.packages // {
  #         "ghc${ghcVersion}" = pkgsOld.haskell.packages."ghc${ghcVersion}".override (old: {
  #           overrides = pkgsNew.lib.composeExtensions (old.overrides or (_: _: {  }))
  #             (haskellPackagesNew: haskellPackagesOld: {
  #               ormolu = pkgsNew.haskell.lib.overrideCabal
  #                 haskellPackagesOld.ormolu
  #                 (_: { enableSeparateBinOutput = false; });
  #             });
  #         });
  #       };
  #     };
  #   })
  # ];

  # [24.05] Futile effort to get ghcup working.
  # nixpkgs.overlays = [
  #   (pkgsNew: pkgsOld: {
  #     haskellPackages = pkgsOld.haskellPackages.override {
  #       overrides = hfinal: hprev: {
  #         haskus-utils-variant = hprev.haskus-utils-variant.overrideAttrs (oldAttrs: {
  #           meta.broken = false;
  #           doCheck = false;
  #         });
  #       };
  #     };
  #   })
  # ];

  # Packages I want on my personal computer, not necessarily every machine.
  home.packages = with pkgs; [
    # CLI utilities
    ffmpeg
    qpdf

    # Arduino
    # avrdude
    # pkgsCross.avr.buildPackages.gcc
    # dfu-programmer

    # Document preparation
    texlive.combined.scheme-full

    # OCaml
    opam

    # Haskell
    ghc
    cabal-install
    haskell-language-server
    coq

    # Interactive theorem proving
    # (agda.withPackages (p: [ p.standard-library ]))

    # Node
    nodePackages.nodejs

    # Rust
    rustup

    # WebAssembly
    wasm-pack
  ];

  # Extend $PATH without clobbering.
  home.sessionPath = lib.mkAfter [];

  programs.git = {
    userEmail = "slim@sarahlim.com";
    userName = "Slim Lim";
  };

  programs.firefox.profiles.slim = {
    extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
      (buildFirefoxXpiAddon {
        pname = "1password-classic";
        version = "0.3.2";
        addonId = "onepassword4@agilebits.com";
        url = "https://cdn.agilebits.com/dist/1P/ext/1Password-4.7.5.90.xpi";
        sha256 = "sha256-Kpg9Q5H949NzJJDpTnfc7ZNAFOAnMLVk3aPgaOC29/s=";
        meta = {};
      })
    ];
  };
}
