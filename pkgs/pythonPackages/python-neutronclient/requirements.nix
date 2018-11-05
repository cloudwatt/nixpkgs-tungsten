# generated using pypi2nix tool (version: 1.8.1)
# See more at: https://github.com/garbas/pypi2nix
#
# COMMAND:
#   pypi2nix -V 2.7 -r requirements.txt --setup-requires traceback2 --setup-requires six --setup-requires pbr --setup-requires argparse -e python-neutronclient==6.9.0 -e argparse -e setuptools_scm
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
    python = pkgs.python27Full;
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
        name = "python27Full-interpreter";
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
          ln -s ${pythonPackages.python.executable}               python2
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

    "Babel" = python.mkDerivation {
      name = "Babel-2.6.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/be/cc/9c981b249a455fa0c76338966325fc70b7265521bad641bf2932f77712f4/Babel-2.6.0.tar.gz"; sha256 = "8cba50f48c529ca3fa18cf81fa9403be176d374ac4d60738b839122dfaaa3d23"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pytz"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://babel.pocoo.org/";
        license = licenses.bsdOriginal;
        description = "Internationalization utilities";
      };
    };



    "PyYAML" = python.mkDerivation {
      name = "PyYAML-3.12";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/4a/85/db5a2df477072b2902b0eb892feb37d88ac635d36245a72a6a69b23b383a/PyYAML-3.12.tar.gz"; sha256 = "592766c6303207a20efc445587778322d7f73b161bd994f227adaa341ba212ab"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pyyaml.org/wiki/PyYAML";
        license = licenses.mit;
        description = "YAML parser and emitter for Python";
      };
    };



    "appdirs" = python.mkDerivation {
      name = "appdirs-1.4.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/48/69/d87c60746b393309ca30761f8e2b49473d43450b150cb08f3c6df5c11be5/appdirs-1.4.3.tar.gz"; sha256 = "9e5896d1372858f8dd3344faf4e5014d21849c756c8d5701f78f8a103b372d92"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/ActiveState/appdirs";
        license = licenses.mit;
        description = "A small Python module for determining appropriate platform-specific dirs, e.g. a \"user data dir\".";
      };
    };



    "argparse" = python.mkDerivation {
      name = "argparse-1.4.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/18/dd/e617cfc3f6210ae183374cd9f6a26b20514bbb5a792af97949c5aacddf0f/argparse-1.4.0.tar.gz"; sha256 = "62b089a55be1d8949cd2bc7e0df0bddb9e028faefc8c32038cc84862aefdd6e4"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/ThomasWaldmann/argparse/";
        license = licenses.psfl;
        description = "Python command-line parsing library";
      };
    };



    "certifi" = python.mkDerivation {
      name = "certifi-2018.4.16";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/4d/9c/46e950a6f4d6b4be571ddcae21e7bc846fcbb88f1de3eff0f6dd0a6be55d/certifi-2018.4.16.tar.gz"; sha256 = "13e698f54293db9f89122b0581843a782ad0934a4fe0172d2a980ba77fc61bb7"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://certifi.io/";
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



    "cliff" = python.mkDerivation {
      name = "cliff-2.12.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b7/61/a717d704aff14639f0e13fdf6035f0a9860700cda77281414ba1592ad718/cliff-2.12.0.tar.gz"; sha256 = "9d75969ce763f4288b9e2bda0c54cd714321e0fd8be771a4510ab29b55ff8dcb"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."PyYAML"
      self."cmd2"
      self."pbr"
      self."prettytable"
      self."pyparsing"
      self."six"
      self."stevedore"
      self."unicodecsv"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/cliff/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Command Line Interface Formulation Framework";
      };
    };



    "cmd2" = python.mkDerivation {
      name = "cmd2-0.8.7";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/1a/f5/95f5c93367676b5120abcf15f127c0b67229bcc3e507dd02bc2cc06241f7/cmd2-0.8.7.tar.gz"; sha256 = "f9e0dadbfa600afcc532c95a7cb958a8daf66d58ebcab1d3c138bb7d0379a3e1"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."contextlib2"
      self."enum34"
      self."pyparsing"
      self."pyperclip"
      self."six"
      self."subprocess32"
      self."wcwidth"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/python-cmd2/cmd2";
        license = licenses.mit;
        description = "cmd2 - a tool for building interactive command line applications in Python";
      };
    };



    "contextlib2" = python.mkDerivation {
      name = "contextlib2-0.5.5";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/6e/db/41233498c210b03ab8b072c8ee49b1cd63b3b0c76f8ea0a0e5d02df06898/contextlib2-0.5.5.tar.gz"; sha256 = "509f9419ee91cdd00ba34443217d5ca51f5a364a404e1dce9e8979cea969ca48"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://contextlib2.readthedocs.org";
        license = licenses.psfl;
        description = "Backports and enhancements for the contextlib module";
      };
    };



    "debtcollector" = python.mkDerivation {
      name = "debtcollector-1.19.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/44/db/6b54be9367110bc40468f3bcc75b115ab655a9fdd993a4ed01862fdb8d80/debtcollector-1.19.0.tar.gz"; sha256 = "4e90683553a6bb68d10a29b42c5df90d0e83d5085ff1ac2970c91314acdf8719"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."funcsigs"
      self."pbr"
      self."six"
      self."wrapt"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/debtcollector/latest";
        license = "License :: OSI Approved :: Apache Software License";
        description = "A collection of Python deprecation patterns and strategies that help you collect your technical debt in a non-destructive manner.";
      };
    };



    "decorator" = python.mkDerivation {
      name = "decorator-4.3.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/6f/24/15a229626c775aae5806312f6bf1e2a73785be3402c0acdec5dbddd8c11e/decorator-4.3.0.tar.gz"; sha256 = "c39efa13fbdeb4506c476c9b3babf6a718da943dab7811c206005a4a956c080c"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/micheles/decorator";
        license = licenses.bsdOriginal;
        description = "Better living through Python with decorators";
      };
    };



    "deprecation" = python.mkDerivation {
      name = "deprecation-2.0.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/a6/06/f8277cb1a52cda3cfa874bb79cb46aaa0599d2acdcb7d65782d0596d4360/deprecation-2.0.3.tar.gz"; sha256 = "af3180b9aa53e5d3e0ff23934bd14963c7d6effd39c5c8c21973bf1dff8e8479"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."packaging"
      self."unittest2"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://deprecation.readthedocs.io/";
        license = licenses.asl20;
        description = "A library to handle automated deprecations";
      };
    };



    "dogpile.cache" = python.mkDerivation {
      name = "dogpile.cache-0.6.5";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/65/24/7bd97e9d486c37ac03ef6ae3a590db1a8e02183e5d7ce9071bcca9d86c44/dogpile.cache-0.6.5.tar.gz"; sha256 = "631197e78b4471bb0e93d0a86264c45736bc9ae43b4205d581dcc34fbe9b5f31"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://bitbucket.org/zzzeek/dogpile.cache";
        license = licenses.bsdOriginal;
        description = "A caching front-end based on the Dogpile lock.";
      };
    };



    "enum34" = python.mkDerivation {
      name = "enum34-1.1.6";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/bf/3e/31d502c25302814a7c2f1d3959d2a3b3f78e509002ba91aea64993936876/enum34-1.1.6.tar.gz"; sha256 = "8ad8c4783bf61ded74527bffb48ed9b54166685e4230386a9ed9b1279e2df5b1"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://bitbucket.org/stoneleaf/enum34";
        license = licenses.bsdOriginal;
        description = "Python 3.4 Enum backported to 3.3, 3.2, 3.1, 2.7, 2.6, 2.5, and 2.4";
      };
    };



    "funcsigs" = python.mkDerivation {
      name = "funcsigs-1.0.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/94/4a/db842e7a0545de1cdb0439bb80e6e42dfe82aaeaadd4072f2263a4fbed23/funcsigs-1.0.2.tar.gz"; sha256 = "a7bb0f2cf3a3fd1ab2732cb49eba4252c2af4240442415b4abce3b87022a8f50"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://funcsigs.readthedocs.org";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Python function signatures from PEP362 for Python 2.6, 2.7 and 3.2+";
      };
    };



    "futures" = python.mkDerivation {
      name = "futures-3.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/1f/9e/7b2ff7e965fc654592269f2906ade1c7d705f1bf25b7d469fa153f7d19eb/futures-3.2.0.tar.gz"; sha256 = "9ec02aa7d674acb8618afb127e27fde7fc68994c0437ad759fa094a574adb265"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/agronholm/pythonfutures";
        license = licenses.psfl;
        description = "Backport of the concurrent.futures package from Python 3";
      };
    };



    "idna" = python.mkDerivation {
      name = "idna-2.7";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/65/c4/80f97e9c9628f3cac9b98bfca0402ede54e0563b56482e3e6e45c43c4935/idna-2.7.tar.gz"; sha256 = "684a38a6f903c1d71d6d5fac066b58d7768af4de2b832e426ec79c30daa94a16"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/kjd/idna";
        license = licenses.bsdOriginal;
        description = "Internationalized Domain Names in Applications (IDNA)";
      };
    };



    "ipaddress" = python.mkDerivation {
      name = "ipaddress-1.0.22";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/97/8d/77b8cedcfbf93676148518036c6b1ce7f8e14bf07e95d7fd4ddcb8cc052f/ipaddress-1.0.22.tar.gz"; sha256 = "b146c751ea45cad6188dd6cf2d9b757f6f4f8d6ffb96a023e6f2e26eea02a72c"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/phihag/ipaddress";
        license = licenses.psfl;
        description = "IPv4/IPv6 manipulation library";
      };
    };



    "iso8601" = python.mkDerivation {
      name = "iso8601-0.1.12";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/45/13/3db24895497345fb44c4248c08b16da34a9eb02643cea2754b21b5ed08b0/iso8601-0.1.12.tar.gz"; sha256 = "49c4b20e1f38aa5cf109ddcd39647ac419f928512c869dc01d5c7098eddede82"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://bitbucket.org/micktwomey/pyiso8601";
        license = licenses.mit;
        description = "Simple module to parse ISO 8601 dates";
      };
    };



    "jmespath" = python.mkDerivation {
      name = "jmespath-0.9.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e5/21/795b7549397735e911b032f255cff5fb0de58f96da794274660bca4f58ef/jmespath-0.9.3.tar.gz"; sha256 = "6a81d4c9aa62caf061cb517b4d9ad1dd300374cd4706997aff9cd6aedd61fc64"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/jmespath/jmespath.py";
        license = licenses.mit;
        description = "JSON Matching Expressions";
      };
    };



    "jsonpatch" = python.mkDerivation {
      name = "jsonpatch-1.23";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9a/7d/bcf203d81939420e1aaf7478a3efce1efb8ccb4d047a33cb85d7f96d775e/jsonpatch-1.23.tar.gz"; sha256 = "49f29cab70e9068db3b1dc6b656cbe2ee4edf7dfe9bf5a0055f17a4b6804a4b9"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."jsonpointer"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/stefankoegl/python-json-patch";
        license = licenses.bsdOriginal;
        description = "Apply JSON-Patches (RFC 6902) ";
      };
    };



    "jsonpointer" = python.mkDerivation {
      name = "jsonpointer-2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/52/e7/246d9ef2366d430f0ce7bdc494ea2df8b49d7a2a41ba51f5655f68cfe85f/jsonpointer-2.0.tar.gz"; sha256 = "c192ba86648e05fdae4f08a17ec25180a9aef5008d973407b581798a83975362"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/stefankoegl/python-json-pointer";
        license = licenses.bsdOriginal;
        description = "Identify specific nodes in a JSON document (RFC 6901) ";
      };
    };



    "keystoneauth1" = python.mkDerivation {
      name = "keystoneauth1-3.8.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fd/67/7cae86f7e68dc9294f48c9eb181b6bd41bc80738b33a7f5ff0dd29ec3327/keystoneauth1-3.8.0.tar.gz"; sha256 = "d64350c4d5e27c750e872433f539a9937104c4401ab255c1198fc13f1d203764"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."PyYAML"
      self."iso8601"
      self."os-service-types"
      self."oslo.config"
      self."oslo.utils"
      self."pbr"
      self."requests"
      self."six"
      self."stevedore"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/keystoneauth/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Authentication Library for OpenStack Identity";
      };
    };



    "linecache2" = python.mkDerivation {
      name = "linecache2-1.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/44/b0/963c352372c242f9e40db02bbc6a39ae51bde15dddee8523fe4aca94a97e/linecache2-1.0.0.tar.gz"; sha256 = "4b26ff4e7110db76eeb6f5a7b64a82623839d595c2038eeda662f2a2db78e97c"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/testing-cabal/linecache2";
        license = licenses.psfl;
        description = "Backports of the linecache module";
      };
    };



    "monotonic" = python.mkDerivation {
      name = "monotonic-1.5";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/19/c1/27f722aaaaf98786a1b338b78cf60960d9fe4849825b071f4e300da29589/monotonic-1.5.tar.gz"; sha256 = "23953d55076df038541e648a53676fb24980f7a1be290cdda21300b3bc21dfb0"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/atdt/monotonic";
        license = "License :: OSI Approved :: Apache Software License";
        description = "An implementation of time.monotonic() for Python 2 & < 3.3";
      };
    };



    "msgpack" = python.mkDerivation {
      name = "msgpack-0.5.6";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f3/b6/9affbea179c3c03a0eb53515d9ce404809a122f76bee8fc8c6ec9497f51f/msgpack-0.5.6.tar.gz"; sha256 = "0ee8c8c85aa651be3aa0cd005b5931769eaa658c948ce79428766f1bd46ae2c3"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://msgpack.org/";
        license = licenses.asl20;
        description = "MessagePack (de)serializer.";
      };
    };



    "munch" = python.mkDerivation {
      name = "munch-2.3.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/68/f4/260ec98ea840757a0da09e0ed8135333d59b8dfebe9752a365b04857660a/munch-2.3.2.tar.gz"; sha256 = "6ae3d26b837feacf732fb8aa5b842130da1daf221f5af9f9d4b2a0a6414b0d51"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/Infinidat/munch";
        license = licenses.mit;
        description = "A dot-accessible dictionary (a la JavaScript objects).";
      };
    };



    "netaddr" = python.mkDerivation {
      name = "netaddr-0.7.19";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/0c/13/7cbb180b52201c07c796243eeff4c256b053656da5cfe3916c3f5b57b3a0/netaddr-0.7.19.tar.gz"; sha256 = "38aeec7cdd035081d3a4c306394b19d677623bf76fa0913f6695127c7753aefd"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/drkjam/netaddr/";
        license = licenses.bsdOriginal;
        description = "A network address manipulation library for Python";
      };
    };



    "netifaces" = python.mkDerivation {
      name = "netifaces-0.10.7";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/81/39/4e9a026265ba944ddf1fea176dbb29e0fe50c43717ba4fcf3646d099fe38/netifaces-0.10.7.tar.gz"; sha256 = "bd590fcb75421537d4149825e1e63cca225fd47dad861710c46bd1cb329d8cbd"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/al45tair/netifaces";
        license = licenses.mit;
        description = "Portable network interface information.";
      };
    };



    "openstacksdk" = python.mkDerivation {
      name = "openstacksdk-0.14.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/bd/02/77dea6b6da978ece6076b8ca27a57dee62119f3a687ce13a25364bce7a75/openstacksdk-0.14.0.tar.gz"; sha256 = "e86e46bb9a54c490dabb44d741496cb8a4d664aa5b8e0ff7429af35bc4f5ce48"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."PyYAML"
      self."appdirs"
      self."decorator"
      self."deprecation"
      self."dogpile.cache"
      self."futures"
      self."ipaddress"
      self."iso8601"
      self."jmespath"
      self."jsonpatch"
      self."keystoneauth1"
      self."munch"
      self."netifaces"
      self."os-service-types"
      self."pbr"
      self."requestsexceptions"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://developer.openstack.org/sdks/python/openstacksdk/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "An SDK for building applications to work with OpenStack";
      };
    };



    "os-client-config" = python.mkDerivation {
      name = "os-client-config-1.31.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/80/bb/e7d5c7ae06ccbab1c9a3f8b9ea2a99d16981b66b5f2cad21f1b94a0eca0e/os-client-config-1.31.2.tar.gz"; sha256 = "4e9de6be30d2314bfb40a723ee01fa630e9b6764e0e5680e7418acf1566d0e12"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."openstacksdk"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/os-client-config/latest";
        license = "License :: OSI Approved :: Apache Software License";
        description = "OpenStack Client Configuation Library";
      };
    };



    "os-service-types" = python.mkDerivation {
      name = "os-service-types-1.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b3/22/1d0a1f5fd633fdbdff3ac1191f95773e3277d1138e4cee09a891c9ee51aa/os-service-types-1.2.0.tar.gz"; sha256 = "b08fb4ec1249d313afea2728fa4db916b1907806364126fe46de482671203111"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pbr"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.openstack.org/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Python library for consuming OpenStack sevice-types-authority data";
      };
    };



    "osc-lib" = python.mkDerivation {
      name = "osc-lib-1.10.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/19/d4/e3738123a4bf165f2dab3f74004c189707e25befabe6895faad06afdf0a4/osc-lib-1.10.0.tar.gz"; sha256 = "6b02b8fe036b8e5f722b9de6f14923ae7cb4d90aa4474b70df5aa1fdb113b352"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."cliff"
      self."keystoneauth1"
      self."openstacksdk"
      self."os-client-config"
      self."oslo.i18n"
      self."oslo.utils"
      self."pbr"
      self."simplejson"
      self."six"
      self."stevedore"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/osc-lib/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "OpenStackClient Library";
      };
    };



    "oslo.config" = python.mkDerivation {
      name = "oslo.config-6.2.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/a8/b4/85f50eee25a65f6ce0dca6b4965cf8067bfe23c7c785aedd34b0bb94d042/oslo.config-6.2.1.tar.gz"; sha256 = "c989f7441e5eea658482276d2f34d3c9d77089f4f723076efc442211c3256743"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."PyYAML"
      self."debtcollector"
      self."enum34"
      self."netaddr"
      self."oslo.i18n"
      self."rfc3986"
      self."six"
      self."stevedore"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/oslo.config/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo Configuration API";
      };
    };



    "oslo.context" = python.mkDerivation {
      name = "oslo.context-2.21.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/79/d7/fe6f06ab54056091c4a4a203ed54d26851726a0f7145b4bb68c9ebcb1a47/oslo.context-2.21.0.tar.gz"; sha256 = "163d3d24a90545c2a56a587499027106b5a76d7c9854d2a906e19dd794d6b313"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."debtcollector"
      self."pbr"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/oslo.context/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo Context library";
      };
    };



    "oslo.i18n" = python.mkDerivation {
      name = "oslo.i18n-3.20.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/cc/8d/9514c0f979c858fcbf3c8300769f8323d5c69c20cffe3543059e978329cd/oslo.i18n-3.20.0.tar.gz"; sha256 = "c3cf63c01fa3ff1b5ae7d6445d805c6bf5390ac010725cf126b18eb9086f4c4e"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."pbr"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/oslo.i18n/latest";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo i18n library";
      };
    };



    "oslo.log" = python.mkDerivation {
      name = "oslo.log-3.38.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/62/46/965fbdc8a0320f468276c2cc4431fcfc4931c56de37267b00a191d3196a8/oslo.log-3.38.1.tar.gz"; sha256 = "c374a64832a2e78b0b8eaa2b015a6cfc1c88777a508d5c27816d6e06660c9e81"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."debtcollector"
      self."monotonic"
      self."oslo.config"
      self."oslo.context"
      self."oslo.i18n"
      self."oslo.serialization"
      self."oslo.utils"
      self."pbr"
      self."pyinotify"
      self."python-dateutil"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/oslo.log/latest";
        license = "License :: OSI Approved :: Apache Software License";
        description = "oslo.log library";
      };
    };



    "oslo.serialization" = python.mkDerivation {
      name = "oslo.serialization-2.26.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/6c/ca/5fe5efdb3c4393f7c84c3ae7527a1682c5c5505e6ecea14c526f826b7ccf/oslo.serialization-2.26.0.tar.gz"; sha256 = "2fc16f6e089b9e9f52ed1daaa0a5599a1959781f73f09da2e5de82fac23f9bb2"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."msgpack"
      self."oslo.utils"
      self."pbr"
      self."pytz"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://docs.openstack.org/developer/oslo.serialization/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo Serialization library";
      };
    };



    "oslo.utils" = python.mkDerivation {
      name = "oslo.utils-3.36.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/69/21/bde1fb98e77a0b4d82585c3808e13bfeff28917fb4f7af2f8a0e56530355/oslo.utils-3.36.2.tar.gz"; sha256 = "9900be2bc8bf14c187731393dea672ea9579312d6f31b862e527999fde63f2c6"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."debtcollector"
      self."funcsigs"
      self."iso8601"
      self."monotonic"
      self."netaddr"
      self."netifaces"
      self."oslo.i18n"
      self."pbr"
      self."pyparsing"
      self."pytz"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/oslo.utils/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo Utility library";
      };
    };



    "packaging" = python.mkDerivation {
      name = "packaging-17.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/77/32/439f47be99809c12ef2da8b60a2c47987786d2c6c9205549dd6ef95df8bd/packaging-17.1.tar.gz"; sha256 = "f019b770dd64e585a99714f1fd5e01c7a8f11b45635aa953fd41c689a657375b"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pyparsing"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pypa/packaging";
        license = licenses.bsdOriginal;
        description = "Core utilities for Python packages";
      };
    };



    "pbr" = python.mkDerivation {
      name = "pbr-4.0.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/cd/9f/8f14a51b522c47a315dd969fbdf39233e41f0bfa8b996b4ff0ad852ff43d/pbr-4.0.4.tar.gz"; sha256 = "a9c27eb8f0e24e786e544b2dbaedb729c9d8546342b5a6818d8eda098ad4340d"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/pbr/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Python Build Reasonableness";
      };
    };



    "prettytable" = python.mkDerivation {
      name = "prettytable-0.7.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ef/30/4b0746848746ed5941f052479e7c23d2b56d174b82f4fd34a25e389831f5/prettytable-0.7.2.tar.bz2"; sha256 = "853c116513625c738dc3ce1aee148b5b5757a86727e67eff6502c7ca59d43c36"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://code.google.com/p/prettytable";
        license = licenses.bsdOriginal;
        description = "A simple Python library for easily displaying tabular data in a visually appealing ASCII table format";
      };
    };



    "pyinotify" = python.mkDerivation {
      name = "pyinotify-0.9.6";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e3/c0/fd5b18dde17c1249658521f69598f3252f11d9d7a980c5be8619970646e1/pyinotify-0.9.6.tar.gz"; sha256 = "9c998a5d7606ca835065cdabc013ae6c66eb9ea76a00a1e3bc6e0cfe2b4f71f4"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/seb-m/pyinotify";
        license = licenses.mit;
        description = "Linux filesystem events monitoring";
      };
    };



    "pyparsing" = python.mkDerivation {
      name = "pyparsing-2.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/3c/ec/a94f8cf7274ea60b5413df054f82a8980523efd712ec55a59e7c3357cf7c/pyparsing-2.2.0.tar.gz"; sha256 = "0832bcf47acd283788593e7a0f542407bd9550a55a8a8435214a1960e04bcb04"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pyparsing.wikispaces.com/";
        license = licenses.mit;
        description = "Python parsing module";
      };
    };



    "pyperclip" = python.mkDerivation {
      name = "pyperclip-1.6.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/33/15/f3c29b381815ae75e27589583655f4a8567721c541b8ba8cd52f76868655/pyperclip-1.6.2.tar.gz"; sha256 = "43496f0a1f363a5ecfc4cda5eba6a2a3d5056fe6c7ffb9a99fbb1c5a3c7dea05"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/asweigart/pyperclip";
        license = licenses.bsdOriginal;
        description = "A cross-platform clipboard module for Python. (Only handles plain text for now.)";
      };
    };



    "python-dateutil" = python.mkDerivation {
      name = "python-dateutil-2.7.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/a0/b0/a4e3241d2dee665fea11baec21389aec6886655cd4db7647ddf96c3fad15/python-dateutil-2.7.3.tar.gz"; sha256 = "e27001de32f627c22380a688bcc43ce83504a7bc5da472209b4c70f02829f0b8"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://dateutil.readthedocs.io";
        license = licenses.bsdOriginal;
        description = "Extensions to the standard Python datetime module";
      };
    };



    "python-keystoneclient" = python.mkDerivation {
      name = "python-keystoneclient-3.16.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/17/2f/87f6c87a9c2f935bcc45f3c3c60275e5ce297ce36a89af46d3d6f5c1c00a/python-keystoneclient-3.16.0.tar.gz"; sha256 = "0658240b39cced18784c8c4c0bed24d42f06c048103b397a55992a9e0da01c4a"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."debtcollector"
      self."keystoneauth1"
      self."oslo.config"
      self."oslo.i18n"
      self."oslo.serialization"
      self."oslo.utils"
      self."pbr"
      self."requests"
      self."six"
      self."stevedore"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/python-keystoneclient/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Client Library for OpenStack Identity";
      };
    };



    "python-neutronclient" = python.mkDerivation {
      name = "python-neutronclient-6.9.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ce/c0/8c1eb986be1bbed597395f20f09438e1694843b301fa070df8ed6b3e7023/python-neutronclient-6.9.0.tar.gz"; sha256 = "2e9ce009832ca91752ad76f7c18a2d9e8babf8c9c4a92b476195c422a4647321"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."cliff"
      self."debtcollector"
      self."iso8601"
      self."keystoneauth1"
      self."netaddr"
      self."os-client-config"
      self."osc-lib"
      self."oslo.i18n"
      self."oslo.log"
      self."oslo.serialization"
      self."oslo.utils"
      self."pbr"
      self."python-keystoneclient"
      self."requests"
      self."simplejson"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/python-neutronclient/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "CLI and Client Library for OpenStack Networking";
      };
    };



    "pytz" = python.mkDerivation {
      name = "pytz-2018.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/10/76/52efda4ef98e7544321fd8d5d512e11739c1df18b0649551aeccfb1c8376/pytz-2018.4.tar.gz"; sha256 = "c06425302f2cf668f1bba7a0a03f3c1d34d4ebeef2c72003da308b3947c7f749"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pythonhosted.org/pytz";
        license = licenses.mit;
        description = "World timezone definitions, modern and historical";
      };
    };



    "requests" = python.mkDerivation {
      name = "requests-2.19.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/54/1f/782a5734931ddf2e1494e4cd615a51ff98e1879cbe9eecbdfeaf09aa75e9/requests-2.19.1.tar.gz"; sha256 = "ec22d826a36ed72a7358ff3fe56cbd4ba69dd7a6718ffd450ff0e9df7a47ce6a"; };
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



    "requestsexceptions" = python.mkDerivation {
      name = "requestsexceptions-1.4.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/82/ed/61b9652d3256503c99b0b8f145d9c8aa24c514caff6efc229989505937c1/requestsexceptions-1.4.0.tar.gz"; sha256 = "b095cbc77618f066d459a02b137b020c37da9f46d9b057704019c9f77dba3065"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.openstack.org/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Import exceptions from potentially bundled packages in requests.";
      };
    };



    "rfc3986" = python.mkDerivation {
      name = "rfc3986-1.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/4b/f6/8f0a24e50454494b0736fe02e6617e7436f2b30148b8f062462177e2ca2d/rfc3986-1.1.0.tar.gz"; sha256 = "8458571c4c57e1cf23593ad860bb601b6a604df6217f829c2bc70dc4b5af941b"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://rfc3986.readthedocs.io";
        license = licenses.asl20;
        description = "Validating URI References per RFC 3986";
      };
    };



    "setuptools-scm" = python.mkDerivation {
      name = "setuptools-scm-2.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e5/62/f9e1ac314464eb5945c97542acb6bf6f3381dfa5d7a658de7730c36f31a1/setuptools_scm-2.1.0.tar.gz"; sha256 = "a767141fecdab1c0b3c8e4c788ac912d7c94a0d6c452d40777ba84f918316379"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pypa/setuptools_scm/";
        license = licenses.mit;
        description = "the blessed package to manage your versions by scm tags";
      };
    };



    "simplejson" = python.mkDerivation {
      name = "simplejson-3.15.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/8b/6c/c512c32124d1d2d67a32ff867bb3cdd5bfa6432660975f7ee753ed7ad886/simplejson-3.15.0.tar.gz"; sha256 = "ad332f65d9551ceffc132d0a683f4ffd12e4bc7538681100190d577ced3473fb"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/simplejson/simplejson";
        license = licenses.mit;
        description = "Simple, fast, extensible JSON encoder/decoder for Python";
      };
    };



    "six" = python.mkDerivation {
      name = "six-1.11.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/16/d8/bc6316cf98419719bd59c91742194c111b6f2e85abac88e496adefaf7afe/six-1.11.0.tar.gz"; sha256 = "70e8a77beed4562e7f14fe23a786b54f6296e34344c23bc42f07b15018ff98e9"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pypi.python.org/pypi/six/";
        license = licenses.mit;
        description = "Python 2 and 3 compatibility utilities";
      };
    };



    "stevedore" = python.mkDerivation {
      name = "stevedore-1.28.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ba/40/92295187c3157c109fde84eb2d4002c2bb3ab5a9c1df09f7fd96e6dfd5c9/stevedore-1.28.0.tar.gz"; sha256 = "f1c7518e7b160336040fee272174f1f7b29a46febb3632502a8f2055f973d60b"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pbr"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/stevedore/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Manage dynamic plugins for Python applications";
      };
    };



    "subprocess32" = python.mkDerivation {
      name = "subprocess32-3.5.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c3/5f/7117737fc7114061837a4f51670d863dd7f7f9c762a6546fa8a0dcfe61c8/subprocess32-3.5.2.tar.gz"; sha256 = "eb2b989cf03ffc7166339eb34f1aa26c5ace255243337b1e22dab7caa1166687"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/google/python-subprocess32";
        license = licenses.psfl;
        description = "A backport of the subprocess module from Python 3 for use on 2.x.";
      };
    };



    "traceback2" = python.mkDerivation {
      name = "traceback2-1.4.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/eb/7f/e20ba11390bdfc55117c8c6070838ec914e6f0053a602390a598057884eb/traceback2-1.4.0.tar.gz"; sha256 = "05acc67a09980c2ecfedd3423f7ae0104839eccb55fc645773e1caa0951c3030"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."linecache2"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/testing-cabal/traceback2";
        license = licenses.psfl;
        description = "Backports of the traceback module";
      };
    };



    "unicodecsv" = python.mkDerivation {
      name = "unicodecsv-0.14.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/6f/a4/691ab63b17505a26096608cc309960b5a6bdf39e4ba1a793d5f9b1a53270/unicodecsv-0.14.1.tar.gz"; sha256 = "018c08037d48649a0412063ff4eda26eaa81eff1546dbffa51fa5293276ff7fc"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/jdunck/python-unicodecsv";
        license = licenses.bsdOriginal;
        description = "Python2's stdlib csv module is nice, but it doesn't support unicode. This module is a drop-in replacement which *does*.";
      };
    };



    "unittest2" = python.mkDerivation {
      name = "unittest2-1.1.0";
      src = pkgs.fetchurl { url = "https://github.com/garbas/unittest2/archive/b70f4cddd32a03fc96f816c9d7faa91f3fcf661f.zip"; sha256 = "efe4e01ed1df356a147470ad76a51f0fed927ce6ec3a89e948174aa9ff84888c"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."argparse"
      self."six"
      self."traceback2"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pypi.python.org/pypi/unittest2";
        license = licenses.bsdOriginal;
        description = "The new features in unittest backported to Python 2.4+.";
      };
    };



    "urllib3" = python.mkDerivation {
      name = "urllib3-1.23";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/3c/d2/dc5471622bd200db1cd9319e02e71bc655e9ea27b8e0ce65fc69de0dac15/urllib3-1.23.tar.gz"; sha256 = "a68ac5e15e76e7e5dd2b8f94007233e01effe3e50e8daddf69acfd81cb686baf"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."certifi"
      self."idna"
      self."ipaddress"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://urllib3.readthedocs.io/";
        license = licenses.mit;
        description = "HTTP library with thread-safe connection pooling, file post, and more.";
      };
    };



    "wcwidth" = python.mkDerivation {
      name = "wcwidth-0.1.7";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/55/11/e4a2bb08bb450fdbd42cc709dd40de4ed2c472cf0ccb9e64af22279c5495/wcwidth-0.1.7.tar.gz"; sha256 = "3df37372226d6e63e1b1e1eda15c594bca98a22d33a23832a90998faa96bc65e"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/jquast/wcwidth";
        license = licenses.mit;
        description = "Measures number of Terminal column cells of wide-character codes";
      };
    };



    "wrapt" = python.mkDerivation {
      name = "wrapt-1.10.11";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/a0/47/66897906448185fcb77fc3c2b1bc20ed0ecca81a0f2f88eda3fc5a34fc3d/wrapt-1.10.11.tar.gz"; sha256 = "d4d560d479f2c21e1b5443bbd15fe7ec4b37fe7e53d335d3b9b0a7b1226fe3c6"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/GrahamDumpleton/wrapt";
        license = licenses.bsdOriginal;
        description = "Module for decorators, wrappers and monkey patching.";
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