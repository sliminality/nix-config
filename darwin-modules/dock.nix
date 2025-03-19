# Generates a `defaults write` command to populate the Dock with shortcuts.

{ lib, config, dockItems, ... }:

let 
  plistUtils = import ./plist.nix { inherit lib; };

  writeTiles = tiles:
    "defaults write com.apple.dock persistent-others -array \\
      ${builtins.concatStringsSep " \\\n\t" tiles}";

  # Double quote avoids <> escaping as shell redirects.
  quote = s: "\"${s}\"";

  tiles = map plistUtils.mkPlist dockItems;
  quotedTiles = map quote tiles;

in

# builtins.trace (writeTiles quotedTiles)
writeTiles quotedTiles
