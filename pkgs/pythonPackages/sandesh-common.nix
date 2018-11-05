{ buildPythonPackage
, pythonPackages
, contrailVersion
, contrailPythonBuild
}:

buildPythonPackage rec {
  pname = "sandesh-common";
  version = contrailVersion;
  name = "${pname}-${version}";
  src = "${contrailPythonBuild}/production/sandesh/common/";
  propagatedBuildInputs = with pythonPackages; [  ];
}
