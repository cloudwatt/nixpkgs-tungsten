{ pkgs, python }:

self: super: {
"six" = pkgs.pythonPackages.six ;
"pyparsing" = pkgs.pythonPackages.pyparsing ;
"pbr" = pkgs.pythonPackages.pbr ;
"certifi" = pkgs.pythonPackages.certifi ;
"urllib3" = pkgs.pythonPackages.urllib3 ;
"netaddr" = pkgs.pythonPackages.netaddr ;
"stevedore" = pkgs.pythonPackages.stevedore ;
"netifaces" = pkgs.pythonPackages.netifaces ;
"chardet" = pkgs.pythonPackages.chardet ;
"requests" = pkgs.pythonPackages.requests ;
"idna" = pkgs.pythonPackages.idna ;
}
