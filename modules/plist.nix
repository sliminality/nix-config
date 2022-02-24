# Converts an attribute set into a plist.

{ lib, ... }:

with builtins;

let 
  writeBool = x: if x then "true" else "false";

in
rec {
  removeNewlines = builtins.replaceStrings ["\n"] [""];
  removeSpaces = s: let
    tokens = split "[[:space:]]+" s;
    nonSpaces = filter isString tokens;
  in concatStringsSep "" nonSpaces;

  clean = s: removeNewlines s;

  mkString = s: "<string>${s}</string>";
  mkInt = n: "<integer>${toString n}</integer>";
  mkReal = n: "<real>${toString n}</real>";
  mkBool = x: "<${writeBool x}/>";

  mkArray = xs: clean
    ''<array>${concatStringsSep "\n" (map mkPlist xs)}</array>'';

  mkField = key: value: clean
    ''<key>${key}</key>${mkPlist value}'';

  mkDict = attrs: clean
    ''<dict>${concatStringsSep "\n" (lib.mapAttrsToList mkField attrs)}</dict>'';

  mkPlist = x: 
    if isString x then mkString x else
    if isInt    x then mkInt x else
    if isFloat  x then mkReal x else
    if isBool   x then mkBool x else
    if isList   x then mkArray x else
    if isAttrs  x then mkDict x else
    throw "invalid value type";

  # # Converts an attribute set into a list of attribute path statements.
  # flatten = let go = path: key: value:
  #     let path' = path ++ [key]; in
  #       # If the value is an attribute set, recursively flatten. 
  #       if isAttrs value then flatten path' value else
  #       # If the value is not an attribute set, return that assignment.
  #       "${concatStringsSep ":" path'} = ${writeVal false value};";
  #   in path: attrs:
  #     concatStringsSep "\n" (lib.mapAttrsToList (f path) attrs);
}
