{ pythonPackages
, contrailVersion
, contrailWorkspace
}:

pythonPackages.buildPythonPackage rec {
  pname = "contrail-vrouter-api";
  version = contrailVersion;
  name = "${pname}-${version}";
  src = "${contrailWorkspace}/controller/src/vnsw/contrail-vrouter-api/";
}
