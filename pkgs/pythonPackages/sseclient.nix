{ pkgs
, buildPythonPackage
}:

buildPythonPackage rec {
  pname = "sseclient";
  version = "1.7";
  name = "${pname}-${version}";
  src = pkgs.fetchFromGitHub {
    owner = "mpetazzoni";
    repo = "sseclient";
    rev = "sseclient-py-1.7";
    sha256 = "0iar4w8gryhjzqwy5k95q9gsv6xpmnwxkpz33418nw8hxlp86wfl";
  };
}
