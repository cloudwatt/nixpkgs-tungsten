{pkgs, sources, isContrail32 }:

pkgs.stdenv.mkDerivation {
  name = "sandesh";
  version = "3.2";

  src = sources.sandesh;
  patches = pkgs.lib.optional isContrail32 [
    (pkgs.fetchurl {
      name = "sandesh.patch";
      url = "https://github.com/Juniper/contrail-sandesh/commit/8b6c1388e9574ab971952734c71d0a5f6ecb8280.patch";
      sha256 = "01gsik13al3zj31ai2r1fg37drv2q0lqnmfvqi736llkma1hc7ik";
    })
    # Some introspects links are missing
    # See https://bugs.launchpad.net/juniperopenstack/+bug/1691949
    (pkgs.fetchurl {
      url = "https://github.com/Juniper/contrail-sandesh/commit/4074d8af7592a564ba1c55c23021cc95f105c6c1.patch";
      sha256 = "1jz4z4y72fqgwpwrmw29pismvackwy187k2yc2xdis8dwrkhpzni";
    })
  ];
  installPhase = "mkdir $out; cp -r * $out";
}
