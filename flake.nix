{
  description = "Development environment";

  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/nixpkgs-unstable"; };
    flake-utils = { url = "github:numtide/flake-utils"; };
    nix2container = { url = "github:nlewo/nix2container"; };
  };

  outputs = { self, nixpkgs, flake-utils, nix2container }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        elixir_overlay = (self: super: rec {
          erlang = super.erlangR25;
          beamPackages = super.beam.packagesWith erlang;
          elixir = super.elixir_1_14;
          hex = beamPackages.hex.override { inherit elixir;};
          rebar3 = beamPackages.rebar3;
          buildMix = super.beam.packages.erlang.buildMix'.override { inherit elixir erlang hex; };
        }
        );

        inherit (nixpkgs.lib) optional;
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ elixir_overlay ];
        };

        nix2containerPkgs = nix2container.packages.${system};

      in
      with pkgs;
      rec  {
        packages = rec {
          orca = callPackage ./default.nix { };
          container = callPackage ./container.nix { inherit orca nix2containerPkgs; };
        };

        defaultPackage = packages.orca;
        devShell = callPackage ./shell.nix { };
      }
    );

}
