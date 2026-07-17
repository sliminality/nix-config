{ lib, stdenv, src }:

stdenv.mkDerivation {
  pname = "sf-pro";
  version = "0.0.0";

  inherit src;

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
