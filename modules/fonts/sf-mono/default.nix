{ lib, stdenv, pkgs }:

stdenv.mkDerivation rec {
  pname = "sf-mono";
  version = "0.0.0";

  src = pkgs.fetchFromGitHub {
    owner = "supercomputra";
    repo = "SF-Mono-Font";
    rev = "1409ae79074d204c284507fef9e479248d5367c1";
    sha256 = "sha256-3wG3M4Qep7MYjktzX9u8d0iDWa17FSXYnObSoTG2I/o=";
  };

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
