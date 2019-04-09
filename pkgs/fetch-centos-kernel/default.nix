{ stdenv, fetchurl, patchelf, glibc, elfutils, cpio, rpm }:

{ centosVersion, kernelVersion, sha256 }:

stdenv.mkDerivation rec {
  inherit kernelVersion;
  pname = "centos-${centosVersion}-kernel-devel";
  name = "${pname}-${kernelVersion}";
  src = fetchurl {
    url = "http://mirror.centos.org/centos/${centosVersion}/os/x86_64/Packages/kernel-devel-${kernelVersion}.rpm";
    inherit sha256;
  };
  phases = [ "unpackPhase" "installPhase" ];
  buildInputs = [ rpm cpio ];
  unpackCmd = "rpm2cpio $curSrc | cpio -idm";
  installPhase = ''
    mkdir -p $out/lib/modules/${kernelVersion}
    mv src/kernels/${kernelVersion} $out/lib/modules/${kernelVersion}/build

    for i in recordmcount basic/fixdep mod/modpost ; do
      ${patchelf}/bin/patchelf \
        --set-interpreter ${stdenv.glibc}/lib/ld-linux-x86-64.so.2 \
        --set-rpath ${stdenv.glibc}/lib \
        $out/lib/modules/${kernelVersion}/build/scripts/$i
    done

    ${patchelf}/bin/patchelf \
      --set-interpreter ${stdenv.glibc}/lib/ld-linux-x86-64.so.2 \
      --set-rpath ${stdenv.glibc}/lib:${elfutils}/lib \
      $out/lib/modules/${kernelVersion}/build/tools/objtool/objtool
  '';
}
