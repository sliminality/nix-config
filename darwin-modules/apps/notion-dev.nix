{ lib, stdenv, pkgs }:

# Thanks to https://cmacr.ae/post/2020-05-09-managing-firefox-on-macos-with-nix/

stdenv.mkDerivation rec {
  pname = "Notion Dev";
  version = "3.0.134";

  src = pkgs.fetchurl {
    name = "NotionDev.dmg";
    url = "https://dev.notion.so/desktop/apple-silicon/download";
    sha256 = "sha256-ofC8GDap7LdxrL0ebuMEMbXz0bWm73r2Yb4SfYtvLuI=";
  };

  buildInputs = [ pkgs.undmg ];
  sourceRoot = ".";  # Otherwise the unpacker produces multiple directories.
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    mkdir -p "$out/Applications"
    cp -pR "Notion Dev.app" "$out/Applications/Notion Dev.app"
  '';

  meta = {
    description = "Notes and databases for you and your team";
    homepage = "https://notion.so/desktop";
    platforms = lib.platforms.darwin;
    maintainers = [];
  };
}
