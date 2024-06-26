# Based on ref: https://codeberg.org/adamcstephens/apple-fonts.nix
{ lib, stdenv, fetchurl, ... }:

let
  makeAppleFont =
    name: pkgName: src:
    stdenv.mkDerivation {
      inherit name src;

      version = "0.3.0";

      unpackPhase = ''
        undmg $src
        7z x '${pkgName}'
        7z x 'Payload~'
      '';

      buildInputs = [
        undmg
        p7zip
      ];
      setSourceRoot = "sourceRoot=`pwd`";

      installPhase = ''
        mkdir -p $out/share/fonts
        mkdir -p $out/share/fonts/opentype
        mkdir -p $out/share/fonts/truetype
        find -name \*.otf -exec mv {} $out/share/fonts/opentype/ \;
        find -name \*.ttf -exec mv {} $out/share/fonts/truetype/ \;
      '';
    };

  sources = import ./sources.nix;
in

{
  sf-pro = makeAppleFont "sf-pro" "SF Pro Fonts.pkg" (fetchurl sources.sf-pro);
  sf-compact = makeAppleFont "sf-compact" "SF Compact Fonts.pkg" (fetchurl sources.sf-compact);
  sf-mono = makeAppleFont "sf-mono" "SF Mono Fonts.pkg" (fetchurl sources.sf-mono);
  sf-arabic = makeAppleFont "sf-arabic" "SF Arabic Fonts.pkg" (fetchurl sources.sf-arabic);
  ny = makeAppleFont "ny" "NY Fonts.pkg" (fetchurl sources.ny);
}
