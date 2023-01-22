{ pkgs }:

with pkgs;

let
  pname = "orca";
  version = "0.0.1";

  src = ./.;

  tailwind = nodePackages.tailwindcss;
  mixFodDeps = beamPackages.fetchMixDeps {
    MIX_TAILWIND_PATH="${tailwind}/bin/tailwind";
    MIX_TAILWIND_VERSION="${tailwind.version}";

    pname = "mix-deps-${pname}";
    inherit src version elixir;
    sha256 =  "sha256-+VmUSvyR83nBLeSNUOiFd0kRhahqcy3nKRSdW0AatcQ=";
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

  postBuild = ''
    export NODE_PATH="assets/node_modules"
    mkdir -p assets/node_modules

    ln -s ${mixFodDeps}/phoenix assets/node_modules/phoenix
    ln -s ${mixFodDeps}/phoenix_html assets/node_modules/phoenix_html
    ln -s ${mixFodDeps}/phoenix_live_view assets/node_modules/phoenix_live_view
    mix assets.deploy --no-deps-check
  '';
}

