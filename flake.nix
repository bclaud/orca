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

        inherit (nixpkgs.lib) optional;
        pkgs = import nixpkgs {
          inherit system;
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
