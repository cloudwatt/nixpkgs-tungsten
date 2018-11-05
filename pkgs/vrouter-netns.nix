{ pkgs
, contrailVersion
, contrailWorkspace
, pythonPackages
}:

pythonPackages.buildPythonApplication rec {
  name = "contrail-vrouter-netns-${version}";
  version = contrailVersion;
  src = "${contrailWorkspace}/controller/src/vnsw/opencontrail-vrouter-netns/";
  patchPhase = ''
    substituteInPlace requirements.txt --replace "docker-py" "docker"
    substituteInPlace opencontrail_vrouter_netns/lxc_manager.py --replace "dhclient" "${pkgs.dhcp}/bin/dhclient"
  '';
  # Try to access /var/log/contrail/contrail-lbaas-haproxy-stdout.log
  doCheck = false;
  propagatedBuildInputs = with pythonPackages; [
    docker netaddr contrail_vrouter_api eventlet vnc_api cfgm_common
  ];
  makeWrapperArgs = with pkgs; [
    "--prefix PATH : ${iptables}/bin:${procps}/bin:${nettools}/bin:${iproute}/bin:${sudo}/bin"
  ];
}
