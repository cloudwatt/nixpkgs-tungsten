{ nixpkgs ? <nixpkgs> }:

let bootstrap_pkgs = import nixpkgs {};
in {
  pkgs = bootstrap_pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    # Belong to the branch release-18.03-cloudwatt
    rev = "4166986dfad56fd559fe513821e029ce967e4f67";
    sha256 = "0634zy4g5flhhjkf34lvrccrrq258dhy421n0jmy1z1gdf3r42b2";};
  }
