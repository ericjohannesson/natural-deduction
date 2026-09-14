{ pkgs ? import <nixpkgs> {} }:
let
  build_packages = with pkgs; [
    ocaml
    ocamlPackages.findlib
    ocamlPackages.uuseg
  ];
  dev_packages = with pkgs; [
    ocamlPackages.utop
    gh
    gh-markdown-preview
  ];
in
pkgs.mkShell {
  packages = (
    build_packages
    ++
    dev_packages
  );
}
