{ contrailPkgs, pkgs, fetchzip, stdenv, makeWrapper, openjdk }:

stdenv.mkDerivation rec {
  name = "gremlin-server-${version}";
  version = "3.3.2";
  src = fetchzip {
    url = "http://www-eu.apache.org/dist/tinkerpop/${version}/apache-tinkerpop-gremlin-server-${version}-bin.zip";
    sha256 = "0plx7m51av0kjr6x4rbsmsz5p03j980gh56czj3rfin10565v5kr";
  };
  buildInputs = [ makeWrapper openjdk ];
  installPhase = ''
    mkdir -p $out/{bin,opt}
    cp -r * $out/opt
    ln -s $out/opt/bin/gremlin-server.sh $out/bin/gremlin-server
  '';
  # Not sure /tmp/gremlin is a good choice...
  postFixup = ''
    wrapProgram "$out/bin/gremlin-server" --prefix PATH ":" "${openjdk}/bin/" --suffix JAVA_OPTIONS " " "-Dtinkerpop.ext=/tmp/gremlin/"
  '';
}
