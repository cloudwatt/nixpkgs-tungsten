{ pkgs, fetchzip, stdenv, makeWrapper, openjdk }:

stdenv.mkDerivation rec {
  name = "gremlin-console-${version}";
  version = "3.3.1";
  src = fetchzip {
    url = "http://www-eu.apache.org/dist/tinkerpop/${version}/apache-tinkerpop-gremlin-console-${version}-bin.zip";
    sha256 = "1qbx0i1gf5rbnfnyfrmc1jz4dxsjdshbdz3449s67fkc3fskx4gm";
  };
  buildInputs = [ makeWrapper openjdk ];
  installPhase = ''
    mkdir -p $out/{bin,opt}
    cp -r * $out/opt
    ln -s $out/opt/bin/gremlin.sh $out/bin/gremlin
  '';
  # Not sure /tmp/gremlin is a good choice...
  postFixup = ''
    wrapProgram "$out/bin/gremlin" --prefix PATH ":" "${openjdk}/bin/" --set JAVA_OPTIONS -Dtinkerpop.ext=/tmp/gremlin/
  '';
}
