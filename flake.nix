{
  description = "natural-deduction";

  inputs = {
    nixpkgs-linux.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url      = "github:numtide/flake-utils";
  };
  outputs = {
    self, nixpkgs-linux, nixpkgs-darwin, nixpkgs-unstable, flake-utils
  }:
    let
      linux-systems  = [
        # TODO "aarch64-linux"
        "x86_64-linux"
      ];
      darwin-systems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      ## windows-systems = [
      ##   # TODO "x86_64-windows"
      ## ];
      systems = linux-systems ++ darwin-systems; ## TODO ++ windows-systems;
      version = "0";
    in
      flake-utils.lib.eachSystem systems (system:
        let
          nixpkgs      = (
            if      builtins.elem system linux-systems  then
              nixpkgs-linux
            else if builtins.elem system darwin-systems then
              nixpkgs-darwin
            else
              nixpkgs-unstable
          );
          pkgs          = nixpkgs.legacyPackages.${system};
          pkgs_common   = [
            pkgs.bash
            pkgs.gnumake
          ];
          pkgs_ocaml    = [
            pkgs.ocaml
            pkgs.ocamlPackages.findlib
            pkgs.ocamlPackages.menhir
            pkgs.ocamlPackages.uuseg
          ];
        in {
          devShells.default = pkgs.mkShell {
            buildInputs = (
              pkgs_common
              ++
              pkgs_ocaml
            );
          };
          devShells.ocaml = pkgs.mkShell {
            buildInputs = pkgs_common ++ pkgs_ocaml;
          };
          packages.default = pkgs.stdenv.mkDerivation {
            name        = "natural-deduction-${version}";
            buildInputs = (
              [pkgs.makeWrapper]
              ++
              pkgs_common
              ++
              pkgs_ocaml
            );
            src          = ./.;
            buildPhase   = ''
              make nd
            '';
            installPhase = ''
              mkdir -p $out/bin
              cp nd $out/bin/
            '';
          };
          apps.default = {
            type    = "app";
            program = "${self.packages.${system}.default}/bin/nd";
          };
        }
      );
}
