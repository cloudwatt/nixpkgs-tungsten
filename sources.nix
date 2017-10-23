{ pkgs }:
{
build = pkgs.fetchFromGitHub {
  owner = "Juniper";
  repo = "contrail-build";
  rev = "0256e45652bf03b08eaf0dd599dfbe6015e6a773";
  sha256 = "0r24diqfm3f3bwq3imdivyima8z38w6pj670x61sr6dzy49wx6h4";
};
controller = pkgs.fetchFromGitHub {
  owner = "Juniper";
  repo = "contrail-controller";
  rev = "c2dcb9be7a0cb5636cf9488ae2c5938e5965b226";
  sha256 = "1z83aiygp9lh08m270x7nf01bw06lzqbjzgx7ik7dqmdr2g3w79w";
};
generateds = pkgs.fetchFromGitHub {
  owner = "Juniper";
  repo = "contrail-generateds";
  rev = "94b3381963ac373b3cec7ad4f8ada2c3ac0a2491";
  sha256 = "03jk11plwa1klbpac6cj3mnqgg1pzyd402plmsa2qc6wwcylab9f";
};
neutronPlugin = pkgs.fetchFromGitHub {
  owner = "Juniper";
  repo = "contrail-neutron-plugin";
  rev = "e34ac768d275e6d5f00fde8c4a3bb416d57d2922";
  sha256 = "0xycwjklnflwalm9cw6mav60s8qxf81q7v498zhhsi2ndyvblwsf";
};
sandesh = pkgs.fetchFromGitHub {
  owner = "Juniper";
  repo = "contrail-sandesh";
  rev = "be6504d469a8befb059ef0150c4fc6ff1b6a0a8a";
  sha256 = "1pv5dli3a3a79chmg11vp6b8dg1sy15hgbpal3xwwqrprbwisb3d";
};
thirdPartySrc = pkgs.fetchFromGitHub {
  owner = "Juniper";
  repo = "contrail-third-party";
  rev = "bed878908a8bc83b671ffa881d0f9f4dcacdf058";
  sha256 = "1ayzmwr33r0dml5zr5vcmh300ih68i03s44m57yww7xjs54v0rh0";
};
vrouter = pkgs.fetchFromGitHub {
  owner = "Juniper";
  repo = "contrail-vrouter";
  rev = "c9fda449066946a9bfdfa4dd84736adc552ce0c6";
  sha256 = "1w3wlyn7r6gm3ij58x42r30gvcl9m3haqsfrdm8rpq6n76rq871g";
};
webController = pkgs.fetchFromGitHub {
  owner = "Juniper";
  repo = "contrail-web-controller";
  rev = "0cab188a5bdb67361b70d95a40a51e30831c347f";
  sha256 = "1c2n8w1wcrh8ybkagx8f8clvmgrdsg935hp3s9g6viyjsvnz78qf";
};
webCore = pkgs.fetchFromGitHub {
  owner = "Juniper";
  repo = "contrail-web-core";
  rev = "32372991c9d7d2522cc049adbfe43369bfbc128d";
  sha256 = "0axrbh46pcc5s1wdv63w5igwdnlp9c1j9pwyppgn3sc89zxz19js";
};
webuiThirdParty = pkgs.fetchFromGitHub {
  owner = "Juniper";
  repo = "contrail-webui-third-party";
  rev = "874fb15af5b056810080393f96ba3fbeb2cf1b34";
  sha256 = "1ays8calyg9wxn9gzi8vnp4a1i2hdrhc51hd2k5ny6xf3jmrsqbl";
};
}
