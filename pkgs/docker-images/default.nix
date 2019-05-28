{ pkgs, runCommand, dockerTools, contrail50 }:

let
  tungstenApi = dockerTools.pullImage {
    imageName = "docker.io/opencontrailnightly/contrail-controller-config-api";
    imageDigest = "sha256:7ebb285df2fdd512f6b885b772e6b2383ad1f23488d6a767f8bb21e55239fe62";
    finalImageTag = "latest";
    sha256 = "1qpw5vdvga3qd66rzdfsdw3wc51jf7hd9k16l41yphqrwc2ng75h";
  };

  tungstenSchema = dockerTools.pullImage {
    imageName = "docker.io/opencontrailnightly/contrail-controller-config-schema";
    imageDigest = "sha256:b6bc624a05de7d554df37096431f1ea0ea2086368e9f96fbdf1868f5eeb53a16";
    finalImageTag = "latest";
    sha256 = "06kz45wfgnyzi717dv79im263pl5pwpxklangqd3a6hzh4xd7g8p";
  };
  
  # This is because symlinked directory in the parent image are not
  # supported by nixpkgs.dockerTools.buildImage:/
  # See https://github.com/NixOS/nixpkgs/issues/57073
  toUsrBin = drv: runCommand "${drv.name}-to-usr-bin" {} ''
    mkdir -p $out/usr/bin/
    for i in $(ls ${drv}/bin/); do
      ln -s ${drv}/bin/$i $out/usr/bin/$i
    done
  '';

in {
  contrailApi = dockerTools.buildImage {
    name = "contrail-api";
    tag = "r5.0";
    fromImage = tungstenApi;
    contents = toUsrBin contrail50.apiServer;
    config = {
      Env = [
            "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
            "PS1=\\033[1m($(printenv NODE_TYPE)-$(printenv SERVICE_NAME))\\033[m\\017[$(id -un)@$(hostname -s) $(pwd)]$ "
            "NODE_TYPE=config"
            "SERVICE_NAME=api"
      ];
      Cmd = [
            "/usr/bin/contrail-api"
            "--conf_file"
            "/etc/contrail/contrail-api.conf"
            "--conf_file"
            "/etc/contrail/contrail-keystone-auth.conf"
            "--worker_id"
            "0"
      ];
      Entrypoint = [ "/entrypoint.sh" ];
    };
  };
  contrailSchema = dockerTools.buildImage {
    name = "contrail-schema";
    tag = "r5.0";
    fromImage = tungstenSchema;
    contents = toUsrBin contrail50.schemaTransformer;
    config = {
      Entrypoint = [ "/entrypoint.sh" ];
    };
  };

  # TODO: Add all other images. Since binaries already exist, it's a
  # trivial task.
}
