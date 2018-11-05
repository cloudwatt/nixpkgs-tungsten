{ pkgs, stdenv }:

stdenv.mkDerivation rec {
  name = "cassandra-cpp-driver";
  version = "2.7";
   src = pkgs.fetchFromGitHub {
    owner = "datastax";
    repo = "cpp-driver";
    rev = "d5152deeeb188c1a1cb285233ffd98c6e9261e0c";
    sha256 = "0rwmfmm3npk92j7rg0nmhm6lb2njpc5n81jb20mdww8hm858mnj8";
  };

  phases = [ "unpackPhase" "buildPhase" "installPhase" "fixupPhase"];

  buildInputs = with pkgs; [ cmake libuv openssl gcc6 ];

  buildPhase = ''
  mkdir build
  pushd build
  cmake ..
  make
  popd
  '';

  installPhase = ''
  mkdir $out
  mkdir $out/include
  mkdir $out/lib
  cp include/cassandra.h $out/include/
  cp build/libcassandra* $out/lib/
  '';
}
