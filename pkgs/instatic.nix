{
  lib,
  stdenv,
  bun,
  makeWrapper,
  fetchFromGitHub,
  runCommand,
  bun2nix,
}:

let
  version = "0.0.13";

  upstream = fetchFromGitHub {
    owner = "CoreBunch";
    repo = "Instatic";
    rev = "v${version}";
    hash = "sha256-LDll9oVhRtC9XcqAYpfEYTxUGcUVFdMNawOIsyR12E0=";
  };

  src = runCommand "instatic-src" { } ''
    cp -r ${upstream} $out
    chmod -R +w $out
    cp ${./instatic.bun.nix} $out/bun.nix
  '';

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = "${src}/bun.nix";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "instatic";
  inherit version src;

  nativeBuildInputs = [ bun makeWrapper ];

  preConfigure = ''
    export HOME=$(mktemp -d)
    export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
    cp -rL ${bunDeps}/share/bun-cache/. "$BUN_INSTALL_CACHE_DIR"
  '';

  configurePhase = ''
    bun install --frozen-lockfile
  '';

  buildPhase = ''
    runHook preBuild
    bun run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    rm -rf node_modules
    bun install --frozen-lockfile --production

    mkdir -p $out/lib/instatic $out/bin

    cp -rL dist server src node_modules package.json bun.lock tsconfig*.json $out/lib/instatic/

    makeWrapper ${bun}/bin/bun $out/bin/instatic \
      --add-flags "run $out/lib/instatic/server/index.ts" \
      --chdir "$out/lib/instatic"

    runHook postInstall
  '';

  meta = {
    description = "Self-hosted CMS with an integrated visual editor";
    homepage = "https://instatic.com";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
})
