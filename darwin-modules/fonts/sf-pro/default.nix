{ lib, stdenv, pkgs }:
# with (import <nixpkgs> {});

stdenv.mkDerivation rec {
  pname = "sf-pro";
  version = "0.0.0";

  src = pkgs.fetchFromGitHub {
    owner = "sahibjotsaggu";
    repo = "San-Francisco-Pro-Fonts";
    rev = "8bfea09aa6f1139479f80358b2e1e5c6dc991a58";
    sha256 = "sha256-mAXExj8n8gFHq19HfGy4UOJYKVGPYgarGd/04kUIqX4=";
  };

  installPhase = ''
    install -m 444 -Dt $out/share/fonts/opentype *.otf 
  '';

  meta = {
    description = "Neutral, flexible, sans-serif typeface used as the system font for iOS, iPad OS, macOS and tvOS";
    homepage = "https://developer.apple.com/fonts/";
    platforms = lib.platforms.darwin;
    maintainers = [];
  };
}
