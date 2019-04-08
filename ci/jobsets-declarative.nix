{ nixpkgs, declInput, pulls }:
let
  pkgs = import nixpkgs {};
  prs = builtins.fromJSON (builtins.readFile pulls);
  prJobsets =  pkgs.lib.mapAttrs (num: info:
    { enabled = 1;
      hidden = false;
      description = "PR ${num}: ${info.title}";
      nixexprinput = "contrail";
      nixexprpath = "jobset.nix";
      checkinterval = 60;
      schedulingshares = 20;
      enableemail = false;
      emailoverride = "";
      keepnr = 1;
      inputs = {
        contrail = {
          type = "git";
          value = "git://github.com/${info.base.repo.owner.login}/${info.base.repo.name}.git pull/${num}/head";
          emailresponsible = false;
        };
        bootstrap_pkgs = {
          value = "https://github.com/NixOS/nixpkgs acd89daabcb47cb882bc72ffc2d01281ed1fecb8";
          type = "git";
          emailresponsible = false;
        };
      };
    }
  ) prs;
  desc = prJobsets // {
    trunk = {
      description = "Build master of nixpkgs-tungsten";
      checkinterval = 60;
      enabled = 1;
      nixexprinput = "contrail";
      nixexprpath = "jobset.nix";
      schedulingshares = 100;
      enableemail = false;
      emailoverride = "";
      keepnr = 3;
      hidden = false;
      inputs = {
        contrail = {
          value = "https://github.com/cloudwatt/nixpkgs-tungsten master";
          type = "git";
          emailresponsible = false;
        };
        bootstrap_pkgs = {
          value = "https://github.com/NixOS/nixpkgs acd89daabcb47cb882bc72ffc2d01281ed1fecb8";
          type = "git";
          emailresponsible = false;
        };
      };
    };
    staging = {
      description = "Build master of nixpkgs-tungsten and follow nixpkgs stable";
      checkinterval = 86400;
      enabled = 1;
      nixexprinput = "contrail";
      nixexprpath = "jobset.nix";
      schedulingshares = 100;
      enableemail = false;
      emailoverride = "";
      keepnr = 1;
      hidden = false;
      inputs = {
        bootstrap_pkgs = {
          value = "https://github.com/NixOS/nixpkgs acd89daabcb47cb882bc72ffc2d01281ed1fecb8";
          type = "git";
          emailresponsible = false;
        };
        contrail = {
          value = "https://github.com/cloudwatt/nixpkgs-tungsten master";
          type = "git";
          emailresponsible = false;
        };
        nixpkgs = {
          value = "https://github.com/NixOS/nixpkgs-channels nixos-19.03";
          type = "git";
          emailresponsible = false;
        };
      };
    };
    unstable = {
      description = "Build master of nixpkgs-tungsten and follow nixpkgs unstable";
      checkinterval = 86400;
      enabled = 1;
      nixexprinput = "contrail";
      nixexprpath = "jobset.nix";
      schedulingshares = 100;
      enableemail = false;
      emailoverride = "";
      keepnr = 1;
      hidden = false;
      inputs = {
        bootstrap_pkgs = {
          value = "https://github.com/NixOS/nixpkgs acd89daabcb47cb882bc72ffc2d01281ed1fecb8";
          type = "git";
          emailresponsible = false;
        };
        contrail = {
          value = "https://github.com/cloudwatt/nixpkgs-tungsten master";
          type = "git";
          emailresponsible = false;
        };
        nixpkgs = {
          value = "https://github.com/NixOS/nixpkgs-channels nixos-unstable";
          type = "git";
          emailresponsible = false;
        };
      };
    };
  };

in {
  jobsets = pkgs.runCommand "spec.json" {} ''
    cat <<EOF
    ${builtins.toXML declInput}
    EOF
    cat >$out <<EOF
    ${builtins.toJSON desc}
    EOF
  '';
}
