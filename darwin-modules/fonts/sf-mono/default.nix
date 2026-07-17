{ lib, stdenv, src }:

stdenv.mkDerivation {
  pname = "sf-mono";
  version = "0.0.0";

  inherit src;

  installPhase = ''
    install -m 444 -Dt $out/share/fonts/opentype *.otf
  '';

  meta = {
    description = "Monospaced variant of Apple's San Francisco system font";
    homepage = "https://developer.apple.com/fonts/";
    platforms = lib.platforms.darwin;
    maintainers = [];
  };
}
