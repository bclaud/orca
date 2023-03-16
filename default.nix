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
    sha256 = "sha256-uzCyO87gxsYJGGF1NgZgOGb8YwGgbK7XnVRznR+WYhU=";

    # set mixEnv to empty make it download deps from all envs
    mixEnv = "";
  };
in

beamPackages.mixRelease {
  inherit mixFodDeps pname version src elixir;

  nativeBuildInputs = [ nodejs tailwind glibcLocalesUtf8 ];
  
  doCheck = true;

  LC_ALL = "en_US.UTF-8";
  LANG = "en_US.UTF-8";

  MIX_ESBUILD_PATH="${esbuild}/bin/esbuild";
  MIX_ESBUILD_VERSION="${esbuild.version}";

  MIX_TAILWIND_PATH="${tailwind}/bin/tailwind";
  MIX_TAILWIND_VERSION="${tailwind.version}";

  # Should be nativeCheckInputs but nothing working atm
  # nativeCheckInputs = [postgresqlTestHook];
  checkInputs = [ postgresql postgresqlTestHook ];


  checkPhase = '' 
  runHook preCheck
  export postgresqlTestSetupCommands=""
  export PGUSER=$(whoami)

  MIX_ENV=test mix test --no-deps-check

  runHook postCheck
  '';

  postBuild = ''
    export NODE_PATH="assets/node_modules"
    mkdir -p assets/node_modules

    ln -s ${mixFodDeps}/phoenix assets/node_modules/phoenix
    ln -s ${mixFodDeps}/phoenix_html assets/node_modules/phoenix_html
    ln -s ${mixFodDeps}/phoenix_live_view assets/node_modules/phoenix_live_view
    mix assets.deploy --no-deps-check
  '';
}

