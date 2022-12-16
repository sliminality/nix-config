{ lib, stdenv, pkgs }:

let 
  nodeEnv = pkgs.callPackage <nixpkgs/pkgs/development/node-packages/node-env.nix> { 
    inherit lib stdenv pkgs;
    inherit (pkgs) nodejs python2 runCommand writeTextFile writeShellScript libtool;
  };
in
  nodeEnv.buildNodePackage rec {
    name = "npm";
    packageName = "npm";
    version = "8.12.1";

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/npm/-/npm-${version}.tgz";
      sha256 = "sha256-AEavKKqtYSdZJ8Oma6zj4G4ys9HYpL5Mwhh+k1cfSjc=";
    };

    production = true;
    bypassCache = true;
    reconstructLock = true;

    meta = {
      description = "a package manager for JavaScript";
      homepage = "https://docs.npmjs.com/";
      platforms = [ "aarch64-darwin" ];
      license = "Artistic-2.0";
    };
  }
