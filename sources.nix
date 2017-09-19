{ pkgs }:
{
  thirdPartySrc = pkgs.fetchFromGitHub {
    owner = "Juniper";
    repo = "contrail-third-party";
    rev = "16333c4e2ecbea2ef5bc38cecf45bfdc78500053";
    sha256 = "1bkrjc8w2c8a4hjz43xr0nsiwmxws2zmg2vvl3qfp32bw4ipvrhv";
  };

  controller = pkgs.fetchFromGitHub {
    owner = "eonpatapon";
    repo = "contrail-controller";
    rev = "df56948839068e5d6312556699a1d54fc591895f";
    sha256 = "102qaibxaz106sr67w66wxidxnipvkky3ar670hzazgyfmrjg8vh";
  };

  neutronPlugin = pkgs.fetchFromGitHub {
      owner = "eonpatapon";
      repo = "contrail-neutron-plugin";
      rev = "fa6b3e80af4537633b3423474c9daa83fabee5e8";
      sha256 = "1j0hg944zsb8hablj1i0lq7w4wdah2lrymhwxsyydxz29zc25876";
  };

  vrouter = pkgs.fetchFromGitHub {
      owner = "Juniper";
      repo = "contrail-vrouter";
      rev = "58c8f58574c569ec8057171f6509d6984bb08520";
      sha256 = "0gwfqqdwph5776kcy2qn1i7472b84jbml8aran6kkbwp52611rk5";
  };

  sandesh = pkgs.fetchFromGitHub {
    owner = "Juniper";
    repo = "contrail-sandesh";
    rev = "3083be8b8d3dc673aa6e6d29d258aca064af96ce";
    sha256 = "16v8n6cg42qsxx5qg5p12sq52m9hpgb19zlami2g67f3h1a526dj";
  };

  generateds = pkgs.fetchFromGitHub {
    owner = "Juniper";
    repo = "contrail-generateds";
    rev = "4dc0fdf96ab0302b94381f97dc059a1dc0b2d69b";
    sha256 = "0v5ifvzsjzaw23y8sbzwhr6wwcsz836p2lziq4zcv7hwvr4ic5gw";
  };

  build = pkgs.fetchFromGitHub {
    owner = "Juniper";
    repo = "contrail-build";
    rev = "84860a733f777e040446890bd6bedf44f7116fcb";
    sha256 = "01ik66w5viljsyqs2dj17vfbgkxhq0k4m91lb2dvkhhq65mwcaxw";
  };

  webuiThirdParty = pkgs.fetchFromGitHub {
    owner = "Juniper";
    repo = "contrail-webui-third-party";
    rev = "e8c29f64a03f611bafd719fd0d3c38aaaf5824a3";
    sha256 = "19xf43nwdrs57k5ssqzbnra3h912px8ywcmb734wvy7v339xvgrb";
  };

  webController = pkgs.fetchFromGitHub {
    owner = "Juniper";
    repo = "contrail-web-controller";
    rev = "97a6f72aa66cfc32a94c4dba49f08dd40d627f6f";
    sha256 = "17s892xb6b0spnkgld2ywb32bvhrrhb1dyqg2fg45izwq7ib6wks";
  };

  webCore = pkgs.fetchFromGitHub {
    owner = "Juniper";
    repo = "contrail-web-core";
    rev = "652086f83c02f36f872b1f70e96a4665566abd8e";
    sha256 = "13f69sxvs0gljkhayjbavq2s3anmv3x68884nlx6n9359rlnvwgj";
  };


}
