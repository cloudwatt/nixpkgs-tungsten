{ pkgs, sources, deps }:

with pkgs;

let
  inherit (deps) nodejs-4_x;

  webui-deps-rev = "${sources.webuiThirdParty.rev}";
  webui-deps-file = "webui-deps-${webui-deps-rev}.tar.xz";
  webui-deps-url = "https://storage.fr1.cloudwatt.com/v1/AUTH_e1cd9b90abb840798055d37b29f1a7d2/nixpkgs-tungsten-webui/${webui-deps-file}";

  pythonWithXml = pkgs.python.withPackages (ps: with ps; [ lxml ]);

  # check ./pkgs/build-webui-deps.nix for information on
  # how to build these dependencies.
  webui-thirdparty-deps = pkgs.fetchzip {
      url = webui-deps-url;
      sha256 = "1rw5q085y2g0zs9fzywjafa38d1ga662hf7fvdaw7ajz02v0yh43";
  };

  webui-build = stdenv.mkDerivation {

    name = "contrail-webui-build";
    sourceRoot = "./.";
    buildInputs = [ rsync bash pythonWithXml openssl nodejs-4_x ];

    srcs = [
      webui-thirdparty-deps
      sources.webCore
      sources.webController
      sources.controller
      sources.apiClient
    ];

    postUnpack = ''
      mkdir tools

      [[ ${sources.controller} != controller ]] && cp -r ${sources.controller} controller
      mv ${sources.webCore.name} contrail-web-core
      mv ${sources.webController.name} contrail-web-controller
      mv ${sources.apiClient.name} contrail-api-client

      rsync -ra ${webui-thirdparty-deps}/node_modules contrail-web-core
      rsync -ra ${webui-thirdparty-deps}/node_modules contrail-web-controller
      rsync -ra ${webui-thirdparty-deps}/* contrail-webui-third-party

      cp -a contrail-web-core/webroot/html/dashboard.tmpl contrail-web-core/webroot/html/dashboard.html
      cp -a contrail-web-core/webroot/html/login.tmpl contrail-web-core/webroot/html/login.html
      cp -a contrail-web-core/webroot/html/login-error.tmpl contrail-web-core/webroot/html/login-error.html
    '';

    postPatch = ''
      patchShebangs ./contrail-web-core/generate-files.sh
      patchShebangs ./contrail-web-core/build-files.sh
      patchShebangs ./contrail-web-core/dev-install.sh
      patchShebangs ./contrail-web-core/generate-keys.sh

      substituteInPlace contrail-web-core/config/config.global.js --replace \
        "/usr/src/contrail/contrail-web-controller" \
        "$(pwd)/contrail-web-controller"

      substituteInPlace contrail-web-core/generate-files.sh --replace \
        "if [ -a ../src/contrail-api-client/schema/all_cfg.xsd ]; then" \
        "if [ -a ../contrail-api-client/schema/all_cfg.xsd ]; then"

      #
      # Fix for https://bugs.launchpad.net/opencontrail/+bug/1721039
      #
      substituteInPlace contrail-api-client/generateds/generateDS.py --replace \
        "parser.parse(infile)" \
        "parser.parse(StringIO.StringIO(infile.getvalue()))"

      substituteInPlace contrail-web-core/generate-files.sh --replace \
        "python ../src/contrail-api-client/generateds/generateDS.py -f -g json-schema -o configJsonSchemas ../src/contrail-api-client/schema/all_cfg.xsd" \
        "python ../contrail-api-client/generateds/generateDS.py -f -g json-schema -o configJsonSchemas ../contrail-api-client/schema/all_cfg.xsd"

      #
      # The doPreStartServer() copies image files to a path in the nix store.
      # We copy the files during the buildPhase instead
      #
      substituteInPlace contrail-web-core/webServerStart.js --replace \
        "doPreStartServer(false);" \
        "" \
    '';

    buildPhase = ''
      cd contrail-web-core

      #
      # Use the template files as they are
      #
      cp -a webroot/html/dashboard.tmpl webroot/html/dashboard.html
      cp -a webroot/html/login.tmpl webroot/html/login.html
      cp -a webroot/html/login-error.tmpl webroot/html/login-error.html

      #
      # Generate json schema files in `src/serverroot/configJsonSchemas` from `apiClient/schema/all_cfg.xsd`
      #
      ./generate-files.sh 'dev-env' webController

      #
      # Copy/generate js/css/asset files to/in `./webroot`
      #
      ./dev-install.sh
      rm -f built_version

      #
      # Run reqquirejs/r.js ('prod-env' argument is unused)
      #
      ./build-files.sh 'prod-env' webController

      #
      # Replace "prod_env" / "dev_env" and add time stamps (all in comments)
      #
      ./prod-dev.sh webroot/html/dashboard.html prod_env dev_env true
      ./prod-dev.sh webroot/html/login.html prod_env dev_env true
      ./prod-dev.sh webroot/html/login-error.html prod_env dev_env true

      #
      # copy files which `doPreStartServer()` in webServerStart.js  would otherwise copy (see patchPhase)
      #
      cp webroot/img/opencontrail-favicon.ico webroot/img/sdn-favicon.ico
      cp webroot/img/opencontrail-logo.png webroot/img/sdn-logo.png

      #
      # symlink files to writeable paths outside of the store
      #
      ln -s /tmp/contrail-web-core-regions.js webroot/common/api/regions.js
      ln -s /tmp/contrail-web-core-menu_wc.xml webroot/menu_wc.xml
      rm -rf config/config.global.js
      ln -s /tmp/contrail-web-core-config.js config/config.global.js

      #
      # generate keys required by jobserver
      #
      chmod +x ./generate-keys.sh
      ./generate-keys.sh

      cd ..
    '';

    installPhase = ''
      mkdir -p $out
      cp -r * $out
    '';
  };

  webController = stdenv.mkDerivation {
    name = "contrail-web-controller";
    version = "5.0";
    src = webui-build;
    installPhase = ''
      mkdir $out
      cp -r contrail-web-controller/* $out
    '';
  };

  webCore = stdenv.mkDerivation {
    name = "contrail-web-core";
    version = "5.0";
    src = webui-build;
    installPhase = ''
      mkdir $out
      cp -r contrail-web-core/* $out
    '';
  };

in
  {
    webCore = webCore;
    webController = webController;
  }
