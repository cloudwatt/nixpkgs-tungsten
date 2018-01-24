{ contrailPkgs, pkgs, fetchzip, stdenv, makeWrapper, openjdk }:

rec {

  gremlinServer = stdenv.mkDerivation rec {
    name = "gremlin-server-${version}";
    version = "3.3.1";
    src = fetchzip {
      url = "http://www-eu.apache.org/dist/tinkerpop/${version}/apache-tinkerpop-gremlin-server-${version}-bin.zip";
      sha256 = "05lgfx1hs9cy0ki6p5668mdrp6cwiwg8i7v9xy46ihjddkx1hv87";
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
  };

  gremlinServerContrail = pkgs.writeShellScriptBin "gremlin-server-contrail" ''
${gremlinServer}/bin/gremlin-server ${contrailPkgs.tools.contrailGremlin}/conf/gremlin-server-contrail.yaml
'';

}
