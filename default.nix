{ pkgs }:

with pkgs;

let
  pname = "orca";
  version = "0.0.1";

  src = ./.;

  tailwind = nodePackages.tailwindcss;
  mixFodDeps = beamPackages.fetchMixDeps {

    pname = "mix-deps-${pname}";
    inherit src version elixir;
    sha256 = "sha256-Xzy2Sb65JaIdiYQ2AAqmBYwsdTm05NCgOPMov53I0Dc=";

    installPhase = ''
      runHook preInstall
      mix deps.get
      find "$TEMPDIR/deps" -path '*/.git/*' -a ! -name HEAD -exec rm -rf {} +
      cp -r --no-preserve=mode,ownership,timestamps $TEMPDIR/deps $out
      runHook postInstall
      ''; 

  };
in

beamPackages.mixRelease {
  inherit mixFodDeps pname version src elixir;

  nativeBuildInputs = [ nodejs tailwind glibcLocalesUtf8 ];

  LC_ALL = "en_US.UTF-8";
  LANG = "en_US.UTF-8";

  MIX_ESBUILD_PATH="${esbuild}/bin/esbuild";
  MIX_ESBUILD_VERSION="${esbuild.version}";

  MIX_TAILWIND_PATH="${tailwind}/bin/tailwind";
  MIX_TAILWIND_VERSION="${tailwind.version}";

  checkNativeInputs = [postgresqlTestHook];
  checkInputs = [ postgresql ];

  postgresqlTestUserOptions = "LOGIN SUPERUSER";
  preCheck = ''
  export PGUSER=$(whoami)
  '';

  checkPhase = "
  runHook preCheck

  echo PGHOST
  echo $PGHOST
  echo $PGHOST
  echo $PGHOST

  MIX_ENV=test mix test --no-deps-check

  runHook postCheck
  ";

  doCheck = true;

  postBuild = ''
    export NODE_PATH="assets/node_modules"
    mkdir -p assets/node_modules

    ln -s ${mixFodDeps}/phoenix assets/node_modules/phoenix
    ln -s ${mixFodDeps}/phoenix_html assets/node_modules/phoenix_html
    ln -s ${mixFodDeps}/phoenix_live_view assets/node_modules/phoenix_live_view
    mix assets.deploy --no-deps-check
  '';
}

