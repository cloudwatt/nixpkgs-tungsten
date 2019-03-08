{ pkgs, runCommand, dockerTools, contrail50 }:

let
  tungstenApi = dockerTools.pullImage {
    imageName = "docker.io/tungstenfabric/contrail-controller-config-api";
    imageDigest = "sha256:780692c30e2de1fba213d631858e91255601609246f576d36e810dee256baa33";
    finalImageTag = "r5.0.1";
    sha256 = "19f7mrda4x5dy92kkiqx15nqnp9fiaw6n97pk1fss5ym30bmjrsg";
  };

  tungstenSchema = dockerTools.pullImage {
    imageName = "docker.io/tungstenfabric/contrail-controller-config-schema";
    imageDigest = "sha256:07a281923e58ec41fa78cee6e57d82fb12fc80518f1eead65b1d53e7604a30d5";
    finalImageTag = "r5.0.1";
    sha256 = "1jb7ap6qg1196kll80x1hhfqvmwwci57vfs6icr4pmyn4kkg2x5w";
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
