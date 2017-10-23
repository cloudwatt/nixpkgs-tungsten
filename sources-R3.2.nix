{ pkgs }:
{
  build = pkgs.fetchFromGitHub {
    owner = "Juniper";
    repo = "contrail-build";
    rev = "a18e25f1fca9c2c75b02faa26189f74b87b9e61f";
    sha256 = "126m7fbrrjxqkaq0wsjdlyllbxl989qrck10i3r3x638g57g4k6c";
  };
  controller = pkgs.fetchFromGitHub {
    owner = "Juniper";
    repo = "contrail-controller";
    rev = "14cd4ff4751ca556ad8c053bc587cf0631bf0ed3";
    sha256 = "02vm35f54485ymzm6gvrvd9mscwxx6k91ygcrv4z43mvwh5vhm5y";
  };
  generateds = pkgs.fetchFromGitHub {
    owner = "Juniper";
    repo = "contrail-generateds";
    rev = "72ee410812e608c3791240fa053ae5a6aca1025e";
    sha256 = "1ljw16sl300d3x1g87vx6p6nqvl268zbky6gggbk7jqhqad55l45";
  };
  neutronPlugin = pkgs.fetchFromGitHub {
    owner = "Juniper";
    repo = "contrail-neutron-plugin";
    rev = "69995f050e76e6c06ad7c5536b8bf892e3f82e60";
    sha256 = "197cv0jgimmmhzs0b3ibcph5ss5b3jwd2nd2bf0azki3k5c9w1zr";
  };
  sandesh = pkgs.fetchFromGitHub {
    owner = "Juniper";
    repo = "contrail-sandesh";
    rev = "b098b464306b3c78e54a46ca4a8a329118f78fae";
    sha256 = "0ggp3lh6xh9sgaviangpy0fz5hw7wvs2hj7ih0s68bms5lybbml6";
  };
  thirdPartySrc = pkgs.fetchFromGitHub {
    owner = "Juniper";
    repo = "contrail-third-party";
    rev = "16333c4e2ecbea2ef5bc38cecf45bfdc78500053";
    sha256 = "1bkrjc8w2c8a4hjz43xr0nsiwmxws2zmg2vvl3qfp32bw4ipvrhv";
  };
  vrouter = pkgs.fetchFromGitHub {
    owner = "Juniper";
    repo = "contrail-vrouter";
    rev = "93bf0b4c12b01a23b4e010d76d0f468df9aa9fa4";
    sha256 = "0jjsr8l0pp9dwh4b67sablfyfwa71gmms23ss3xnskd7c15faibb";
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
    rev = "d9044277f609bc3ecc23eb54ac018cb91bcb2460";
    sha256 = "1kyi8qszbbi5xasm8y28fm9k34fc3xv5wzdxifq332pgd1f1xmfg";
  };
  webuiThirdParty = pkgs.fetchFromGitHub {
    owner = "Juniper";
    repo = "contrail-webui-third-party";
    rev = "6bbffd91b301f4c528b637e883b24532ecac8b5d";
    sha256 = "0s0bqmpvka04vynwy8hck3rjq7zxmnwc8s0wg2fbkb35laiqqld1";
  };
}
