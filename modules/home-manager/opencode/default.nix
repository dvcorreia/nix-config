{ lib, ... }:

let
  isMarkdownFile = name: lib.hasSuffix ".md" name;
  commandName = name: lib.strings.removeSuffix ".md" name;
  markdownFiles = dir: lib.filter isMarkdownFile (builtins.attrNames (builtins.readDir dir));

  loadMdDir =
    dir:
    builtins.listToAttrs (
      map (name: lib.nameValuePair (commandName name) (dir + "/${name}")) markdownFiles
    );
in
{
  programs.opencode = {
    commands = loadMdDir ./commands;
    skills = loadMdDir ./skills;
    agents = loadMdDir ./agents;
  };
}
