# ref: https://github.com/MatthewCroughan/nixcfg/blob/master/modules/default.nix

{ lib }:
let
  inherit (builtins)
    filter
    map
    readDir
    toString
    mapAttrs
    attrNames
    listToAttrs
    ;
  inherit (lib)
    removeSuffix
    nameValuePair
    zipListsWith
    filterAttrs
    hasSuffix
    mapAttrsToList
    foldAttrs
    ;
  inherit (lib.filesystem) listFilesRecursive;

  generateModules =
    folder: prefix:
    let
      findSuffix = suffix: dir: (filter (x: (hasSuffix suffix (toString x))) (listFilesRecursive dir));
      allNixFiles = findSuffix ".nix" folder;
      allModuleNames = map (removeSuffix ".nix") (map baseNameOf allNixFiles);
      zippedList = (
        zipListsWith (x: y: nameValuePair (prefix + "-" + x) (import y)) allModuleNames allNixFiles
      );
    in
    listToAttrs zippedList;
in
{
  inherit generateModules;

  generateModulesAuto =
    root:
    let
      moduleFolderNames = attrNames (filterAttrs (n: v: v == "directory") (readDir (toString root)));
      moduleFolderPaths = map (x: (toString root) + "/" + x) moduleFolderNames;
      zippedList = listToAttrs (
        zipListsWith (x: y: nameValuePair x y) moduleFolderNames moduleFolderPaths
      );
    in
    foldAttrs (item: acc: item) { } (mapAttrsToList (n: v: generateModules v n) zippedList);
}
