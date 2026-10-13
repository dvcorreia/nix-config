{
  lib,
  libusb1,
  systemd,
  bluez,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  nodejs,
  pkg-config,
  python3,
  python3Packages,
  stdenv,
  util-linux,
}:

let
  python = python3.withPackages (
    ps: with ps; [
      garminconnect
      python-dotenv
      pyyaml
    ]
  );
in
buildNpmPackage (finalAttrs: {
  pname = "ble-scale-sync";
  version = "1.26.0";

  src = fetchFromGitHub {
    owner = "KristianP26";
    repo = "ble-scale-sync";
    rev = "e5060b4e43e2d08ecace7e327145c777872ea93f";
    hash = "sha256-mBmSS4Y0WE7KDjKaN+/c/pBpsJBbP821gDLgqrf46PA=";
  };

  npmDepsHash = "sha256-L9EWm4ktWxQF/cQbRKYvru71pUcdio91b3/HbkFcuSw=";

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      bluez
      systemd.dev
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ libusb1 ];

  npmFlags = lib.optionals stdenv.hostPlatform.isDarwin [ "--ignore-scripts" ];

  preBuild = lib.optionalString stdenv.hostPlatform.isDarwin ''
    npm rebuild @stoprocent/noble --build-from-source
  '';

  installPhase = ''
    runHook preInstall

    npm prune --omit=dev ${lib.optionalString stdenv.hostPlatform.isDarwin "--ignore-scripts"}

    appDir=$out/lib/node_modules/${finalAttrs.pname}
    mkdir -p "$appDir" $out/bin
    cp -r dist node_modules garmin-scripts package.json "$appDir"

    makeWrapper ${nodejs}/bin/node $out/bin/ble-scale-sync \
      --add-flags "$appDir/dist/index.js" \
      --prefix PATH : ${
        lib.makeBinPath (
          [ python ]
          ++ lib.optionals stdenv.hostPlatform.isLinux [
            bluez
            systemd
            util-linux
          ]
        )
      }

    runHook postInstall
  '';

  meta = {
    description = "BLE smart scale bridge for Garmin Connect, MQTT, and other exporters";
    homepage = "https://github.com/KristianP26/ble-scale-sync";
    license = lib.licenses.gpl3Only;
    mainProgram = "ble-scale-sync";
    platforms = lib.platforms.unix;
  };
})
