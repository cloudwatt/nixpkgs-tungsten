{ pkgs, stdenv }:

stdenv.mkDerivation rec {
  name = "libgrok";
  src = pkgs.fetchurl {
    url = "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/semicomplete/grok-1.20110708.1.tar.gz";
    sha256 = "1j01sydgaaqyf2yv2fwngybzkl9fgdcg18y3fvgjjl0i0dx8aqik";
  };
  preConfigure = ''
    makeFlags="$makeFlags PREFIX=$out GPERF=${pkgs.gperf_3_0}/bin/gperf"
  '';
  buildInputs = with pkgs; [ pcre.dev tokyocabinet libevent.dev gperf ];
  postInstall = "ln -s libgrok.so $out/lib/libgrok.so.1";
}
