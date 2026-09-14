{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
  name = "natural-deduction";
  version = "0";
  src = ./.;
  buildInputs = with pkgs; [
    ocaml
    ocamlPackages.findlib
    ocamlPackages.uuseg
  ];
  buildPhase = ''
    make natural-deduction
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp natural-deduction $out/bin/
  '';
}
