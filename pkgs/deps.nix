# External dependencies that could be upstreamed

{ pkgs ? import <nixpkgs> {} }:
rec {
  libgrok = pkgs.stdenv.mkDerivation rec {
    name = "libgrok";
    src = pkgs.fetchurl {
      url = "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/semicomplete/grok-1.20110708.1.tar.gz";
      sha256 = "1j01sydgaaqyf2yv2fwngybzkl9fgdcg18y3fvgjjl0i0dx8aqik";
    };
    preConfigure = ''
      makeFlags="$makeFlags PREFIX=$out GPERF=${pkgs.gperf_3_0}/bin/gperf"
    '';
    buildInputs = [ pkgs.pcre.dev pkgs.tokyocabinet pkgs.libevent.dev pkgs.gperf ];
    postInstall = "ln -s libgrok.so $out/lib/libgrok.so.1";
  };

  cassandra-cpp-driver = pkgs.stdenv.mkDerivation rec {
    name = "cassandra-cpp-driver";
    version = "2.7";
     src = pkgs.fetchFromGitHub {
      owner = "datastax";
      repo = "cpp-driver";
      rev = "d5152deeeb188c1a1cb285233ffd98c6e9261e0c";
      sha256 = "0rwmfmm3npk92j7rg0nmhm6lb2njpc5n81jb20mdww8hm858mnj8";
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

  promptToolkit = pkgs.pythonPackages.buildPythonPackage rec {
    pname = "prompt_toolkit";
    version = "1.0.15";
    name = "${pname}-${version}";
    src = pkgs.pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "05v9h5nydljwpj5nm8n804ms0glajwfy1zagrzqrg91wk3qqi1c5";
    };
    propagatedBuildInputs = with pkgs.pythonPackages; [ wcwidth six ];
  };

  contrailApiCli = pkgs.python27Packages.buildPythonApplication {
    name = "contrail-api-cli";
    version = "0";
    src = pkgs.fetchFromGitHub {
      owner = "eonpatapon";
      repo = "contrail-api-cli";
      rev = "6a2777f2f8354a624fc5919befd5c4afc4192aba";
      sha256 = "0xp3kiyih2fi55syfspsb3sz5ha9nilxs0c7yssryg0zjlcvp4in";
    };
    buildInputs = with pkgs.python27Packages; [
      funcsigs mock
    ];
    propagatedBuildInputs = with pkgs.python27Packages; [
      pathlib gevent promptToolkit pygments keystoneauth1 datrie
    ];
  };

  # This version is required by contrail-api. With version 0.12.11,
  # contrail-api fails to read any objects with a useless error
  # message...
  bottle_0_12_1 = pkgs.python27Packages.buildPythonPackage rec {
    version = "0.12.1";
    name = "bottle-${version}";

    src = pkgs.fetchurl {
      url = "mirror://pypi/b/bottle/${name}.tar.gz";
      sha256 = "1z16sydqgbn3dhbrz8afw5sd03ygdzq19cj2a140dxvpklqgcsn4";
    };

    propagatedBuildInputs = with pkgs.python27Packages; [ setuptools ];
  };


}
