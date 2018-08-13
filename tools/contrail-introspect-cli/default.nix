{ buildGoPackage, fetchgit, libxml2, pkgconfig }:

buildGoPackage rec {
  name = "contrail-introspect-cli-${version}";
  version = "2018-08-13";
  rev = "daf7334019fa91e72c4764345b9056ab3410ec89";

  buildInputs = [ libxml2 pkgconfig ];

  goPackagePath = "github.com/nlewo/contrail-introspect-cli";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/nlewo/contrail-introspect-cli.git";
    sha256 = "1vx7acz63jmcrgilkz18y428szxp9h6ndww9hnsxx9gybrvyv9nj";
  };

  goDeps = ./deps.nix;
}
