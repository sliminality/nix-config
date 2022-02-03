# Generates a `defaults write` command to populate the Dock with shortcuts.

{ lib, config, dockItems, ... }:

let 
  plistUtils = import ./plist.nix { inherit lib; };

  mkTileDict = { path, showas, arrangement, displayas }: plistUtils.removeNewlines ''
    "<dict>
      <key>tile-data</key>
      <dict>
        <key>file-data</key>
        <dict>
          <key>_CFURLString</key>
          <string>file://${path}</string>
          <key>_CFURLStringType</key>
          <integer>15</integer>
        </dict>
        <key>showas</key>
        <integer>${toString showas}</integer>
        <key>arrangement</key>
        <integer>${toString arrangement}</integer>
        <key>displayas</key>
        <integer>${toString displayas}</integer>
      </dict>
      <key>tile-type</key>
      <string>directory-tile</string>
    </dict>"
  '';

  writeTiles = tiles:
    "defaults write com.apple.dock persistent-others -array \\
      ${builtins.concatStringsSep " \\\n\t" tiles}";

in

writeTiles (map mkTileDict dockItems)
