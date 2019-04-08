{ nixpkgs ? <nixpkgs> }:

let bootstrap_pkgs = import nixpkgs {};
in {
  pkgs = bootstrap_pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    # Belong to the branch release-19.03
    rev = "c21f08bfedde0f7d00a5ebc85455fb28b9037932";
    sha256 = "0sndhal0a61zzgc8k2lhba356mkrgq0hwf5aa61f6kvpvn4isjmg";
  };
}
