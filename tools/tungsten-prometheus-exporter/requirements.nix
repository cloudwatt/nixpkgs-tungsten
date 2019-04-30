# generated using pypi2nix tool (version: 1.8.1)
# See more at: https://github.com/garbas/pypi2nix
#
# COMMAND:
#   pypi2nix -V 3 -e tungsten-prometheus-exporter
#

{ pkgs ? import <nixpkgs> {}
}:

let

  inherit (pkgs) makeWrapper;
  inherit (pkgs.stdenv.lib) fix' extends inNixShell;

  pythonPackages =
  import "${toString pkgs.path}/pkgs/top-level/python-packages.nix" {
    inherit pkgs;
    inherit (pkgs) stdenv;
    python = pkgs.python3;
    # patching pip so it does not try to remove files when running nix-shell
    overrides =
      self: super: {
        bootstrapped-pip = super.bootstrapped-pip.overrideDerivation (old: {
          patchPhase = old.patchPhase + ''
            sed -i               -e "s|paths_to_remove.remove(auto_confirm)|#paths_to_remove.remove(auto_confirm)|"                -e "s|self.uninstalled = paths_to_remove|#self.uninstalled = paths_to_remove|"                  $out/${pkgs.python35.sitePackages}/pip/req/req_install.py
          '';
        });
      };
  };

  commonBuildInputs = [];
  commonDoCheck = false;

  withPackages = pkgs':
    let
      pkgs = builtins.removeAttrs pkgs' ["__unfix__"];
      interpreter = pythonPackages.buildPythonPackage {
        name = "python3-interpreter";
        buildInputs = [ makeWrapper ] ++ (builtins.attrValues pkgs);
        buildCommand = ''
          mkdir -p $out/bin
          ln -s ${pythonPackages.python.interpreter}               $out/bin/${pythonPackages.python.executable}
          for dep in ${builtins.concatStringsSep " "               (builtins.attrValues pkgs)}; do
            if [ -d "$dep/bin" ]; then
              for prog in "$dep/bin/"*; do
                if [ -f $prog ]; then
                  ln -s $prog $out/bin/`basename $prog`
                fi
              done
            fi
          done
          for prog in "$out/bin/"*; do
            wrapProgram "$prog" --prefix PYTHONPATH : "$PYTHONPATH"
          done
          pushd $out/bin
          ln -s ${pythonPackages.python.executable} python
          ln -s ${pythonPackages.python.executable}               python3
          popd
        '';
        passthru.interpreter = pythonPackages.python;
      };
    in {
      __old = pythonPackages;
      inherit interpreter;
      mkDerivation = pythonPackages.buildPythonPackage;
      packages = pkgs;
      overrideDerivation = drv: f:
        pythonPackages.buildPythonPackage (drv.drvAttrs // f drv.drvAttrs //                                            { meta = drv.meta; });
      withPackages = pkgs'':
        withPackages (pkgs // pkgs'');
    };

  python = withPackages {};

  generated = self: {

    "PyYAML" = python.mkDerivation {
      name = "PyYAML-5.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9f/2c/9417b5c774792634834e730932745bc09a7d36754ca00acf1ccd1ac2594d/PyYAML-5.1.tar.gz"; sha256 = "436bc774ecf7c103814098159fbb84c2715d25980175292c648f2da143909f95"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/yaml/pyyaml";
        license = licenses.mit;
        description = "YAML parser and emitter for Python";
      };
    };



    "certifi" = python.mkDerivation {
      name = "certifi-2019.3.9";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/06/b8/d1ea38513c22e8c906275d135818fee16ad8495985956a9b7e2bb21942a1/certifi-2019.3.9.tar.gz"; sha256 = "b26104d6835d1f5e49452a26eb2ff87fe7090b89dfcaee5ea2212697e1e1d7ae"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://certifi.io/";
        license = licenses.mpl20;
        description = "Python package for providing Mozilla's CA Bundle.";
      };
    };



    "chardet" = python.mkDerivation {
      name = "chardet-3.0.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fc/bb/a5768c230f9ddb03acc9ef3f0d4a3cf93462473795d18e9535498c8f929d/chardet-3.0.4.tar.gz"; sha256 = "84ab92ed1c4d4f16916e05906b6b75a6c0fb5db821cc65e70cbd64a3e2a5eaae"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/chardet/chardet";
        license = licenses.lgpl2;
        description = "Universal encoding detector for Python 2 and 3";
      };
    };



    "confuse" = python.mkDerivation {
      name = "confuse-0.5.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/41/39/30857a64e9530ba184c6546b3bd7e10e6ede91fad70bc2302a21de0a3648/confuse-0.5.0.tar.gz"; sha256 = "b8f5a73ec9d385fda8f91949a426e2d5fc4f2cb6d407272376d6ec340e159c0f"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."PyYAML"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/sampsyo/confuse";
        license = licenses.mit;
        description = "painless YAML configuration";
      };
    };



    "decorator" = python.mkDerivation {
      name = "decorator-4.4.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ba/19/1119fe7b1e49b9c8a9f154c930060f37074ea2e8f9f6558efc2eeaa417a2/decorator-4.4.0.tar.gz"; sha256 = "86156361c50488b84a3f148056ea716ca587df2f0de1d34750d35c21312725de"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/micheles/decorator";
        license = licenses.bsdOriginal;
        description = "Better living through Python with decorators";
      };
    };



    "gevent" = python.mkDerivation {
      name = "gevent-1.4.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ed/27/6c49b70808f569b66ec7fac2e78f076e9b204db9cf5768740cff3d5a07ae/gevent-1.4.0.tar.gz"; sha256 = "1eb7fa3b9bd9174dfe9c3b59b7a09b768ecd496debfc4976a9530a3e15c990d1"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."greenlet"
      self."idna"
      self."requests"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.gevent.org/";
        license = licenses.mit;
        description = "Coroutine-based network library";
      };
    };



    "greenlet" = python.mkDerivation {
      name = "greenlet-0.4.15";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f8/e8/b30ae23b45f69aa3f024b46064c0ac8e5fcb4f22ace0dca8d6f9c8bbe5e7/greenlet-0.4.15.tar.gz"; sha256 = "9416443e219356e3c31f1f918a91badf2e37acf297e2fa13d24d1cc2380f8fbc"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/python-greenlet/greenlet";
        license = licenses.mit;
        description = "Lightweight in-process concurrent programming";
      };
    };



    "idna" = python.mkDerivation {
      name = "idna-2.8";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ad/13/eb56951b6f7950cadb579ca166e448ba77f9d24efc03edd7e55fa57d04b7/idna-2.8.tar.gz"; sha256 = "c357b3f628cf53ae2c4c05627ecc484553142ca23264e593d327bcde5e9c3407"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/kjd/idna";
        license = licenses.bsdOriginal;
        description = "Internationalized Domain Names in Applications (IDNA)";
      };
    };



    "jsonpath-rw" = python.mkDerivation {
      name = "jsonpath-rw-1.4.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/71/7c/45001b1f19af8c4478489fbae4fc657b21c4c669d7a5a036a86882581d85/jsonpath-rw-1.4.0.tar.gz"; sha256 = "05c471281c45ae113f6103d1268ec7a4831a2e96aa80de45edc89b11fac4fbec"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."decorator"
      self."ply"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/kennknowles/python-jsonpath-rw";
        license = licenses.asl20;
        description = "A robust and significantly extended implementation of JSONPath for Python, with a clear AST for metaprogramming.";
      };
    };



    "ply" = python.mkDerivation {
      name = "ply-3.11";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e5/69/882ee5c9d017149285cab114ebeab373308ef0f874fcdac9beb90e0ac4da/ply-3.11.tar.gz"; sha256 = "00c7c1aaa88358b9c765b6d3000c6eec0ba42abca5351b095321aef446081da3"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.dabeaz.com/ply/";
        license = licenses.bsdOriginal;
        description = "Python Lex & Yacc";
      };
    };



    "prometheus-client" = python.mkDerivation {
      name = "prometheus-client-0.6.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/4c/bd/b42db3ec90ffc6be805aad09c1cea4bb13a620d0cd4b21aaa44d13541d71/prometheus_client-0.6.0.tar.gz"; sha256 = "1b38b958750f66f208bcd9ab92a633c0c994d8859c831f7abc1f46724fcee490"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/prometheus/client_python";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Python client for the Prometheus monitoring system.";
      };
    };



    "requests" = python.mkDerivation {
      name = "requests-2.21.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/52/2c/514e4ac25da2b08ca5a464c50463682126385c4272c18193876e91f4bc38/requests-2.21.0.tar.gz"; sha256 = "502a824f31acdacb3a35b6690b5fbf0bc41d63a24a45c4004352b0242707598e"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."certifi"
      self."chardet"
      self."idna"
      self."urllib3"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://python-requests.org";
        license = licenses.asl20;
        description = "Python HTTP for Humans.";
      };
    };



    "six" = python.mkDerivation {
      name = "six-1.12.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/dd/bf/4138e7bfb757de47d1f4b6994648ec67a51efe58fa907c1e11e350cddfca/six-1.12.0.tar.gz"; sha256 = "d16a0141ec1a18405cd4ce8b4613101da75da0e9a7aec5bdd4fa804d0e0eba73"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/benjaminp/six";
        license = licenses.mit;
        description = "Python 2 and 3 compatibility utilities";
      };
    };



    "tungsten-prometheus-exporter" = python.mkDerivation {
      name = "tungsten-prometheus-exporter-0.1.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d5/68/a223554a223fff31892e7bce548fd8a37d267c798968552398c603d61189/tungsten-prometheus-exporter-0.1.1.tar.gz"; sha256 = "0565bdb3e77e4dcc7749a3a2ecfa9caa478a143fe860754900849be935d78b21"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."confuse"
      self."gevent"
      self."jsonpath-rw"
      self."prometheus-client"
      self."requests"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.github.com/cloudwatt/tungsten-prometheus-exporter";
        license = licenses.mit;
        description = "Scrape TungstenFabric/OpenContrail analytics UVEs and provide prometheus endpoint";
      };
    };



    "urllib3" = python.mkDerivation {
      name = "urllib3-1.24.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fd/fa/b21f4f03176463a6cccdb612a5ff71b927e5224e83483012747c12fc5d62/urllib3-1.24.2.tar.gz"; sha256 = "9a247273df709c4fedb38c711e44292304f73f39ab01beda9f6b9fc375669ac3"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."certifi"
      self."idna"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://urllib3.readthedocs.io/";
        license = licenses.mit;
        description = "HTTP library with thread-safe connection pooling, file post, and more.";
      };
    };

  };
  localOverridesFile = ./requirements_override.nix;
  overrides = import localOverridesFile { inherit pkgs python; };
  commonOverrides = [

  ];
  allOverrides =
    (if (builtins.pathExists localOverridesFile)
     then [overrides] else [] ) ++ commonOverrides;

in python.withPackages
   (fix' (pkgs.lib.fold
            extends
            generated
            allOverrides
         )
   )
