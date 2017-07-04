# External dependencies that could be upstreamed

{ pkgs ? import <nixpkgs> {} }:
{
  cassandra-cpp-driver = pkgs.stdenv.mkDerivation rec {
    name = "cassandra-cpp-driver";
    version = "2.5";
     src = pkgs.fetchFromGitHub {
      owner = "datastax";
      repo = "cpp-driver";
      rev = "a57e5d289d1ea500ccd958de6b75a5b4e0519377";
      sha256 = "1zpj9kkw16692dl062khji87i06aya89jncqmblfd1vn0bgbpa18";
    };

    phases = [ "unpackPhase" "buildPhase" "installPhase" "fixupPhase"];

    buildInputs = [ pkgs.cmake pkgs.libuv pkgs.openssl ];

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
  };

  libipfix = pkgs.stdenv.mkDerivation rec {
    name = "libipfix";
    src = pkgs.fetchurl {
      url = " http://sourceforge.net/projects/libipfix/files/libipfix/libipfix_110209.tgz";
      sha256 = "0h7v0sxjjdc41hl5vq2x0yhyn04bczl11bqm97825mivrvfymhn6";
    };
  };
  
  bitarray = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "bitarray";
    version = "0.8.1";
    name = "${pname}-${version}";
    src = pkgs.pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "065bj29dvrr9rc47xkjalgjr8jxwq60kcfbryihkra28dqsh39bx";
    };
  };

  pycassa = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "pycassa";
    version = "1.11.2";
    name = "${pname}-${version}";

    src = pkgs.pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "1nsqjzgn6v0rya60dihvbnrnq1zwaxl2qwf0sr08q9qlkr334hr6";
    };
    # Tests are not executed since they require a cassandra up and
    # running
    doCheck = false;
    propagatedBuildInputs = [ pkgs.pythonPackages.thrift ];
  };

  skopeo = pkgs.buildGoPackage rec {
    name = "skopeo";
    version = "0.1.22";
    goPackagePath = "github.com/projectatomic/skopeo";

    buildInputs = [ pkgs.btrfs-progs pkgs.devicemapper pkgs.pkgconfig pkgs.glib pkgs.ostree pkgs.gpgme.dev ];

    prePatch = ''
      rm -rf integration
    '';

    src = pkgs.fetchFromGitHub {
      owner = "projectatomic";
      repo = "skopeo";
      rev = "5d24b67f5eeeca348966adb412d8119837faa1c2";
      sha256 = "0aivs37bcvx3g22a9r3q1vj2ahw323g1vaq9jzbmifm9k0pb07jy";
    };
  };

}

