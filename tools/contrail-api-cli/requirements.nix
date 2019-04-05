# generated using pypi2nix tool (version: 1.8.1)
# See more at: https://github.com/garbas/pypi2nix
#
# COMMAND:
#   pypi2nix -V 2.7 -e contrail-api-cli-extra
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



    "Pygments" = python.mkDerivation {
      name = "Pygments-2.3.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/64/69/413708eaf3a64a6abb8972644e0f20891a55e621c6759e2c3f3891e05d63/Pygments-2.3.1.tar.gz"; sha256 = "5ffada19f6203563680669ee7f53b64dabbeb100eb51b61996085e99c03b284a"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pygments.org/";
        license = licenses.bsdOriginal;
        description = "Pygments is a syntax highlighting package written in Python.";
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



    "contrail-api-cli" = python.mkDerivation {
      name = "contrail-api-cli-0.4.0rc1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/43/a7/42bbd52d575307fbc064efb9a4f32c4152a06257f7c964c6a276dcca5691/contrail-api-cli-0.4.0rc1.tar.gz"; sha256 = "a609fa49ad6c8ee77fb92d10d52a3241a148cdfa3c913d066f5c8d4b4b479c29"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Pygments"
      self."datrie"
      self."gevent"
      self."keystoneauth1"
      self."pathlib"
      self."prompt-toolkit"
      self."requests"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.github.com/eonpatapon/contrail-api-cli";
        license = licenses.mit;
        description = "Simple CLI program to browse Contrail API server";
      };
    };



    "contrail-api-cli-extra" = python.mkDerivation {
      name = "contrail-api-cli-extra-0.5.9";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/64/94/6ce8e23672489c70541acc0a1408ca58894bd8d27587d8563a4918f159c2/contrail-api-cli-extra-0.5.9.tar.gz"; sha256 = "d674e6e58645c47e3bbf7a946bc6281cba7de101cba12c4df6cd627da1ce46d7"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."contrail-api-cli"
      self."kazoo"
      self."networkx"
      self."prettytable"
      self."pycassa"
      self."pydotplus"
      self."python-keystoneclient"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.github.com/cloudwatt/contrail-api-cli-extra";
        license = licenses.mit;
        description = "Supplementary commands for contrail-api-cli";
      };
    };



    "datrie" = python.mkDerivation {
      name = "datrie-0.7.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/44/5f/bf7e4711f6aa95edb2216b3487eeac719645802259643d341668e65636db/datrie-0.7.1.tar.gz"; sha256 = "7a11371cc2dbbad71d6dfef57ced6e8b384bb377eeb847c63d58f8dc8e8b2023"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/kmike/datrie";
        license = licenses.lgpl2Plus;
        description = "Super-fast, efficiently stored Trie for Python.";
      };
    };



    "debtcollector" = python.mkDerivation {
      name = "debtcollector-1.21.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/10/a4/47d2e058c612778d53a6df65f3a6802198820ac443032cc20b438df78fde/debtcollector-1.21.0.tar.gz"; sha256 = "f6ce5a383ad73c23e1138dbb69bf45d33f4a4bdec38f02dbf2b89477ec5e55bc"; };
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



    "gevent" = python.mkDerivation {
      name = "gevent-1.2.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/1b/92/b111f76e54d2be11375b47b213b56687214f258fd9dae703546d30b837be/gevent-1.2.2.tar.gz"; sha256 = "4791c8ae9c57d6f153354736e1ccab1e2baf6c8d9ae5a77a9ac90f41e2966b2d"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."greenlet"
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



    "kazoo" = python.mkDerivation {
      name = "kazoo-2.6.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/01/d6/77d8067b56ef78326b8cbc85d896e29cb9ceae996a24d752e1cb93011b85/kazoo-2.6.1.tar.gz"; sha256 = "4a73c2c62a7163ca1c4aef82aa042d795560497cc81034f212ef13cc037cc783"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."gevent"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://kazoo.readthedocs.io";
        license = licenses.asl20;
        description = "Higher Level Zookeeper Client";
      };
    };



    "keystoneauth1" = python.mkDerivation {
      name = "keystoneauth1-3.13.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9c/fc/6ef3ab930af98cb7de2f26adb7083939ee78dbda0ee35677b21d41c7dc0e/keystoneauth1-3.13.1.tar.gz"; sha256 = "ed78ed68d1915614e590be428a79c48df09f4f51acb3272b3306d7ae1a59f479"; };
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
      name = "msgpack-0.6.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/81/9c/0036c66234482044070836cc622266839e2412f8108849ab0bfdeaab8578/msgpack-0.6.1.tar.gz"; sha256 = "4008c72f5ef2b7936447dcb83db41d97e9791c83221be13d5e19db0796df1972"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://msgpack.org/";
        license = licenses.asl20;
        description = "MessagePack (de)serializer.";
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
      name = "netifaces-0.10.9";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/0d/18/fd6e9c71a35b67a73160ec80a49da63d1eed2d2055054cc2995714949132/netifaces-0.10.9.tar.gz"; sha256 = "2dee9ffdd16292878336a58d04a20f0ffe95555465fee7c9bd23b3490ef2abf3"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/al45tair/netifaces";
        license = licenses.mit;
        description = "Portable network interface information.";
      };
    };



    "networkx" = python.mkDerivation {
      name = "networkx-2.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f3/f4/7e20ef40b118478191cec0b58c3192f822cace858c19505c7670961b76b2/networkx-2.2.zip"; sha256 = "45e56f7ab6fe81652fb4bc9f44faddb0e9025f469f602df14e3b2551c2ea5c8b"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."PyYAML"
      self."decorator"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://networkx.github.io/";
        license = licenses.bsdOriginal;
        description = "Python package for creating and manipulating graphs and networks";
      };
    };



    "os-service-types" = python.mkDerivation {
      name = "os-service-types-1.6.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/be/47/77b67f9601b3719b0a160c93e3df4c38e037b83d92f765e0efee35d3cf9f/os-service-types-1.6.0.tar.gz"; sha256 = "b7713b21cd27fdd9d5ee6683dac507cb2c5b323decfa78bb0e21b7d3661cb8e2"; };
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



    "oslo.config" = python.mkDerivation {
      name = "oslo.config-6.8.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/53/e5/03ee395f0d9fee8f7e55e69ee3010b9c1d359ffec29f735dd5c76ec10e1d/oslo.config-6.8.1.tar.gz"; sha256 = "7ea34cf642df4d18f92637b58dee92c1667c141aa004ce472e257fafc278ce11"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."PyYAML"
      self."debtcollector"
      self."enum34"
      self."netaddr"
      self."oslo.i18n"
      self."requests"
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



    "oslo.i18n" = python.mkDerivation {
      name = "oslo.i18n-3.23.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/51/d8/01d9b3e17a6135cd412742cf742a3bad5366b349fccb1ef99258f1e12652/oslo.i18n-3.23.1.tar.gz"; sha256 = "2669908357e1e49a754dc0c279512246341ae889176c568b89fd9233e65a6ae1"; };
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



    "oslo.serialization" = python.mkDerivation {
      name = "oslo.serialization-2.28.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/3d/c6/9d18210db0aca8ddb292f1fe8ad25cf7f80970e89c113af90047d5bf0d48/oslo.serialization-2.28.2.tar.gz"; sha256 = "c3c73eb1fa45aaf4cdf3b82a0cf85497a245c7e88e803fdafa29e4315d991eb3"; };
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
        homepage = "https://docs.openstack.org/oslo.serialization/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo Serialization library";
      };
    };



    "oslo.utils" = python.mkDerivation {
      name = "oslo.utils-3.40.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/6a/be/2623aefe3766145d59b224fbc313fd15c53c5f2295b869a5cb50ab800fd0/oslo.utils-3.40.3.tar.gz"; sha256 = "92fdd8b7f5cb079f03648015c186c8292a0a7bba918cdab32fdd1133b83280a1"; };
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



    "pathlib" = python.mkDerivation {
      name = "pathlib-1.0.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ac/aa/9b065a76b9af472437a0059f77e8f962fe350438b927cb80184c32f075eb/pathlib-1.0.1.tar.gz"; sha256 = "6940718dfc3eff4258203ad5021090933e5c04707d5ca8cc9e73c94a7894ea9f"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://pathlib.readthedocs.org/";
        license = licenses.mit;
        description = "Object-oriented filesystem paths";
      };
    };



    "pbr" = python.mkDerivation {
      name = "pbr-5.1.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/97/76/c151aa4a3054ce63bb6bbd32f3541e4ae068534ed8b74ee2687f6773b013/pbr-5.1.3.tar.gz"; sha256 = "8c361cc353d988e4f5b998555c88098b9d5964c2e11acf7b0d21925a66bb5824"; };
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



    "prompt-toolkit" = python.mkDerivation {
      name = "prompt-toolkit-1.0.15";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/8a/ad/cf6b128866e78ad6d7f1dc5b7f99885fb813393d9860778b2984582e81b5/prompt_toolkit-1.0.15.tar.gz"; sha256 = "858588f1983ca497f1cf4ffde01d978a3ea02b01c8a26a8bbc5cd2e66d816917"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
      self."wcwidth"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/jonathanslenders/python-prompt-toolkit";
        license = licenses.bsdOriginal;
        description = "Library for building powerful interactive command lines in Python";
      };
    };



    "pycassa" = python.mkDerivation {
      name = "pycassa-1.11.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/3d/a9/fdf29bb0da3349f144497fad59a3344f6228855636798a88e236b343c17a/pycassa-1.11.2.tar.gz"; sha256 = "264332469e14278c40d6c0712c6857fc076cb35d1bc6068cf2196c63df9758db"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."thrift"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/pycassa/pycassa";
        license = licenses.mit;
        description = "Python client library for Apache Cassandra";
      };
    };



    "pydotplus" = python.mkDerivation {
      name = "pydotplus-2.0.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/60/bf/62567830b700d9f6930e9ab6831d6ba256f7b0b730acb37278b0ccdffacf/pydotplus-2.0.2.tar.gz"; sha256 = "91e85e9ee9b85d2391ead7d635e3d9c7f5f44fd60a60e59b13e2403fa66505c4"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pyparsing"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pydotplus.readthedocs.org/";
        license = licenses.mit;
        description = "Python interface to Graphviz's Dot language";
      };
    };



    "pyparsing" = python.mkDerivation {
      name = "pyparsing-2.3.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b9/b8/6b32b3e84014148dcd60dd05795e35c2e7f4b72f918616c61fdce83d27fc/pyparsing-2.3.1.tar.gz"; sha256 = "66c9268862641abcac4a96ba74506e594c884e3f57690a696d21ad8210ed667a"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pyparsing/pyparsing/";
        license = licenses.mit;
        description = "Python parsing module";
      };
    };



    "python-keystoneclient" = python.mkDerivation {
      name = "python-keystoneclient-3.19.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/0d/e8/c8dc43c31efeff9df29f9a2d3990ac80742e5918c450341f899aabf35eb0/python-keystoneclient-3.19.0.tar.gz"; sha256 = "097ac07ee4f9956cb637abee42a18094b7f916a975f53b7c8fb0d8429fd529be"; };
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



    "pytz" = python.mkDerivation {
      name = "pytz-2018.9";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/af/be/6c59e30e208a5f28da85751b93ec7b97e4612268bb054d0dff396e758a90/pytz-2018.9.tar.gz"; sha256 = "d5f05e487007e29e03409f9398d074e158d920d36eb82eaf66fb1136b0c5374c"; };
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



    "rfc3986" = python.mkDerivation {
      name = "rfc3986-1.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e1/f0/d1571e8891e8e93ebb0fc61fb09c04acf0088bab3fa1cb02eb577e7bc135/rfc3986-1.2.0.tar.gz"; sha256 = "bc3ae4b7cd88a99eff2d3900fcb858d44562fd7f273fc07aeef568b9bb6fc4e1"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://rfc3986.readthedocs.io";
        license = licenses.asl20;
        description = "Validating URI References per RFC 3986";
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



    "stevedore" = python.mkDerivation {
      name = "stevedore-1.30.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/dc/22/a8fec083ae5214d5eb847537b1f28169136e989b56561f472dd2cbe465cd/stevedore-1.30.1.tar.gz"; sha256 = "7be098ff53d87f23d798a7ce7ae5c31f094f3deb92ba18059b1aeb1ca9fec0a0"; };
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



    "thrift" = python.mkDerivation {
      name = "thrift-0.9.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ae/58/35e3f0cd290039ff862c2c9d8ae8a76896665d70343d833bdc2f748b8e55/thrift-0.9.3.tar.gz"; sha256 = "dfbc3d3bd19d396718dab05abaf46d93ae8005e2df798ef02e32793cd963877e"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://thrift.apache.org";
        license = licenses.asl20;
        description = "Python bindings for the Apache Thrift RPC system";
      };
    };



    "urllib3" = python.mkDerivation {
      name = "urllib3-1.24.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b1/53/37d82ab391393565f2f831b8eedbffd57db5a718216f82f1a8b4d381a1c1/urllib3-1.24.1.tar.gz"; sha256 = "de9529817c93f27c8ccbfead6985011db27bd0ddfcdb2d86f3f663385c6a9c22"; };
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
      name = "wrapt-1.11.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/67/b2/0f71ca90b0ade7fad27e3d20327c996c6252a2ffe88f50a95bba7434eda9/wrapt-1.11.1.tar.gz"; sha256 = "4aea003270831cceb8a90ff27c4031da6ead7ec1886023b80ce0dfe0adf61533"; };
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
