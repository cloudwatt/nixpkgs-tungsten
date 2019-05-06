{ pkgs
, stdenv
, deps
, contrailSources
}:

let

  inherit (pkgs) makeWrapper cacert unzip curl rsync;
  inherit (deps) nodejs-4_x;

  pythonWithXml = pkgs.python.withPackages (ps: with ps; [ lxml ]);

in

  stdenv.mkDerivation {
    name = "contrail-webui-fetch-packages";
    src = contrailSources.webuiThirdParty;
    unpackPhase = "cp $src/fetch_packages.py fetch_packages.py";
    buildPhase = ":";
    buildInputs = [ makeWrapper cacert pythonWithXml unzip curl nodejs-4_x ];
    patchPhase = ''
      # do not pollute /tmp
      substituteInPlace fetch_packages.py --replace \
        "_PACKAGE_CACHE='/tmp/cache/' + os.environ['USER'] + '/webui_third_party'" \
        "_PACKAGE_CACHE=os.environ['PWD'] + '/cache/'"

      # do not chdir to the CWD (which would be in the nix store
      substituteInPlace fetch_packages.py --replace \
        "os.chdir(os.path.dirname(os.path.realpath(__file__)))" \
        ""

      # do not remove cached files
      substituteInPlace fetch_packages.py --replace \
        "os.remove(ccfile)" \
        "pass"

      # do not ignore certificates when downloading
      substituteInPlace fetch_packages.py --replace \
        "subprocess.call(['wget', '--no-check-certificate', '-O', ccfile, url])" \
        "subprocess.call(['curl', '-L', '-o', ccfile, url])"
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp fetch_packages.py $out/bin/fetch_packages.py
      chmod +x $out/bin/fetch_packages.py
      wrapProgram $out/bin/fetch_packages.py  \
        --prefix PATH : "${pkgs.lib.makeBinPath [pythonWithXml unzip curl nodejs-4_x ]}" \
        --set SSL_CERT_FILE ${cacert}/etc/ssl/certs/ca-bundle.crt
    '';
  }
