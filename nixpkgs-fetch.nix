{ nixpkgs ? <nixpkgs> }:

let
    rev = "7e88992a8c7b2de0bcb89182d8686b27bd93e46a";
    sha256 = "1f6lf4addczi81hchqbzjlhrsmkrj575dmdjdhyl0jkm7ypy2lgk";
in
  builtins.fetchTarball {
    name = "pinned-18.09-nixpkgs";
    url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
    inherit sha256;
}
