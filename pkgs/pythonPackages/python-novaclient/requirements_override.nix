{ pkgs
, python
}:

self: super: with pkgs.pythonPackages; {
  # We use python libraries from nixpkgs in order ot avoid collision
  # with contrail python dependencies.
  inherit certifi urllib3 chardet requests idna;

  "setuptools-git" = python.mkDerivation {
    name = "setuptools-git-1.2";
    src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d9/c5/396c2c06cc89d4ce2d8ccf1d7e6cf31b33d4466a7c65a67a992adb3c6f29/setuptools-git-1.2.tar.gz"; sha256 = "0i84qjwp5m0l9qagdjww2frdh63r37km1c48mrvbmaqsl1ni6r7z"; };
    doCheck = false;
  };

  "python-novaclient" = python.overrideDerivation super."python-novaclient" (old: {
    buildInputs = old.buildInputs ++ [ self."setuptools-git" ];
  });

}
