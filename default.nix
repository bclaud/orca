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

    # set mixEnv to empty make it download deps from all envs
    mixEnv = "";
  };

  # mixNixDeps works for release but doesn't work for mix test
  mixNixDeps = import ./mix_deps.nix {
    inherit beamPackages lib; 
  };
in

beamPackages.mixRelease {
  inherit  pname version src elixir;
  inherit mixNixDeps;

  nativeBuildInputs = [ nodejs tailwind glibcLocalesUtf8 ];
  buildInputs = [ mix2nix elixir ];

  LC_ALL = "en_US.UTF-8";
  LANG = "en_US.UTF-8";

  MIX_ESBUILD_PATH="${esbuild}/bin/esbuild";
  MIX_ESBUILD_VERSION="${esbuild.version}";

  MIX_TAILWIND_PATH="${tailwind}/bin/tailwind";
  MIX_TAILWIND_VERSION="${tailwind.version}";

  # Should be nativeCheckInputs but nothing working atm
  # nativeCheckInputs = [postgresqlTestHook];
  checkInputs = [ postgresql postgresqlTestHook ];


  # declared mix_deps_path when using mix2nix
  checkPhase = '' 
  runHook preCheck
  #every deps paths are in MIX_DEPS_PATH by mix2nix
  echo $MIX_DEPS_PATH

  #overring deps to mixFodDeps
  export MIX_DEPS_PATH="$TEMPDIR/deps"
  cp --no-preserve=mode -R "${mixFodDeps}" "$MIX_DEPS_PATH"

  export postgresqlTestSetupCommands=""
  export PGUSER=postgres

  MIX_ENV=test mix test --no-deps-check

  runHook postCheck
  '';

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

