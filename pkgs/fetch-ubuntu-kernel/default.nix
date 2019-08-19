{ stdenv, fetchurl, patchelf, dpkg, rsync }:

{ version, amd64File, amd64Sha256, allFile, allSha256 }:

stdenv.mkDerivation rec {
  inherit version amd64File amd64Sha256 allFile allSha256;
  pname = "ubuntu-kernel-headers";
  name = "${pname}-${version}";  
  srcs = [
           (fetchurl {
             url = "http://fr.archive.ubuntu.com/ubuntu/pool/main/l/linux/${amd64File}";
             sha256 = "${amd64Sha256}";
           })
           (fetchurl {
             url = "http://fr.archive.ubuntu.com/ubuntu/pool/main/l/linux/${allFile}";
             sha256 = "${allSha256}";
            })
         ];
  phases = [ "unpackPhase" "installPhase" ];
  buildInputs = [ dpkg ];
  unpackCmd = "dpkg-deb --extract $curSrc tmp/";
  installPhase = ''
    mkdir -p $out
    ${rsync}/bin/rsync -rl * $out/
    # We patch these scripts since they have been compiled for ubuntu
    for i in recordmcount basic/fixdep mod/modpost; do
      ${patchelf}/bin/patchelf --set-interpreter ${stdenv.glibc}/lib/ld-linux-x86-64.so.2 $out/usr/src/linux-headers-${version}/scripts/$i
      ${patchelf}/bin/patchelf --set-rpath ${stdenv.glibc}/lib $out//usr/src/linux-headers-${version}/scripts/$i
    done

    ln -sfT $out/usr/src/linux-headers-${version} $out/lib/modules/${version}/build
  '';
}
