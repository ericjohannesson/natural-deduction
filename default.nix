{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/tags/26.05.tar.gz") {} 
}:
pkgs.stdenv.mkDerivation {
  pname = "natural-deduction";
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
