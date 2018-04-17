{ pkgs, fetchzip, stdenv, makeWrapper, openjdk }:

stdenv.mkDerivation rec {
  name = "gremlin-console-${version}";
  version = "3.3.2";
  src = fetchzip {
    url = "http://www-eu.apache.org/dist/tinkerpop/${version}/apache-tinkerpop-gremlin-console-${version}-bin.zip";
    sha256 = "06vbxiaanqsjlpdn702vqppdapkyxjnrkzz5nvn9as2815p1whr3";
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
