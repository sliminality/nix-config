# Change macOS keyboard shortcuts.
# https://superuser.com/questions/1211108/remove-osx-spotlight-keyboard-shortcut-from-command-line

{ lib, updates, clobbers, ... }:

with builtins;

let
  plistUtils = import ./plist.nix { inherit lib; };

  # For assigning entire dicts, use defaults write.
  mkDefaultsCommand = key: value:
    ''defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add ${key} "${plistUtils.mkPlist value}"'';

  # Use PlistBuddy to perform nested updates, since this is a pain with defaults.
  mkPlistBuddyCommand = key: value:
    ''${plistBuddy} ${plist} -c "Set :AppleSymbolicHotKeys:${key} ${writeVal true value}"'';

  plistBuddy = /usr/libexec/PlistBuddy;
  plist = "~/Library/Preferences/com.apple.symbolichotkeys.plist";

  writeVal = includeType: v:
    if isString v then (if includeType then "string "  else "") + v else
    if isInt    v then (if includeType then "integer " else "") + toString v  else
    if isFloat  v then (if includeType then "real "    else "") + toString v  else
    if isBool   v then (if includeType then "bool "    else "") + writeBool v  else
    if isList   v then (if includeType then "array "   else "") + writeList v else
    throw "invalid value type";

  writeBool = x: if x then "true" else "false";

  writeList = xs: let items = map (writeVal false) xs;
    in "(${builtins.concatStringsSep ", " items})";

  join = concatStringsSep "\n";

in
  ''
    # Set nested fields.
    ${join (lib.mapAttrsToList mkPlistBuddyCommand updates)}

    # Clobber fields.
    ${join (lib.mapAttrsToList mkDefaultsCommand clobbers)}
  ''
