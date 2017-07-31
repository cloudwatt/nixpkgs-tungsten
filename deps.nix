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

  jsonpickle = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "jsonpickle";
    version = "0.9.4";
    name = "${pname}-${version}";
    src = pkgs.pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "0f7rs3v30xhwdmnqhqn9mnm8nxjq3yhp6gdzkg3z8m8lynhr968x";
    };
  };

  sseclient = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "sseclient";
    version = "1.7";
    name = "${pname}-${version}";
    src = pkgs.fetchFromGitHub {
      owner = "mpetazzoni";
      repo = "sseclient";
      rev = "sseclient-py-1.7";
      sha256 = "0iar4w8gryhjzqwy5k95q9gsv6xpmnwxkpz33418nw8hxlp86wfl";
    };
  };
  kafka = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "kafka-python";
    version = "1.3.3";
    name = "${pname}-${version}";
    buildInputs = [ pkgs.pythonPackages.tox ];
    src = pkgs.pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "0i1dia3kixrrxhfwwhhnwrqrvycgzim62n64pfxqzbxz14z4lza6";
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

  # We boot a ubuntu Vm to get the kernel sources and the kernel
  # config. We could find a more simple way to do this such as find a
  # way to download these packages.
  ubuntuKernelHeaders = kernelVersion: pkgs.vmTools.runInLinuxImage (pkgs.stdenv.mkDerivation rec {
    name = "ubuntu-kernel-headers";
    version = kernelVersion;
    phases = [ "installPhase" ];
    diskImage = pkgs.vmTools.diskImageFuns.ubuntu1404x86_64 {
      extraPackages = [ "linux-headers-${kernelVersion}-generic" "linux-headers-${kernelVersion}" ];
    };
    installPhase = ''
      mkdir -p $out
      ${pkgs.rsync}/bin/rsync -rl /usr/src/* $out/

      # We patch these scripts since they have been compiled for ubuntu
      for i in recordmcount basic/fixdep mod/modpost; do
        ${pkgs.patchelf}/bin/patchelf --set-interpreter ${pkgs.stdenv.glibc}/lib/ld-linux-x86-64.so.2 $out/linux-headers-${kernelVersion}-generic/scripts/$i
        ${pkgs.patchelf}/bin/patchelf --set-rpath ${pkgs.stdenv.glibc}/lib $out/linux-headers-${kernelVersion}-generic/scripts/$i
      done;
    '';
  });
}
