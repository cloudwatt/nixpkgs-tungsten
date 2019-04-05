{ pkgs, fetchzip, stdenv, makeWrapper, openjdk }:

stdenv.mkDerivation rec {
  name = "gremlin-console-${version}";
  version = "3.3.6";
  src = fetchzip {
    url = "http://www-eu.apache.org/dist/tinkerpop/${version}/apache-tinkerpop-gremlin-console-${version}-bin.zip";
    sha256 = "1f0h4680l3i74aakspk8r2yaxv9kp3xjsl6j94c5qyy2nan5va6d";
  };
  buildInputs = [ makeWrapper openjdk ];
  installPhase = ''
    mkdir -p $out/{bin,opt}
    cp -r * $out/opt
    ln -s $out/opt/bin/gremlin.sh $out/bin/gremlin-console
  '';
  postFixup = ''
    wrapProgram "$out/bin/gremlin-console" --prefix PATH ":" "${openjdk}/bin/"
  '';
}
