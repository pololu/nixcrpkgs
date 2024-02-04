{ native, host }:
let
  nixpkgs = native.nixpkgs;
in
native.make_derivation rec {
  name = "binutils-${version}-${host}";

  version = "2.40";

  src = nixpkgs.fetchurl {
    url = "mirror://gnu/binutils/binutils-${version}.tar.xz";
    hash = "sha256-D4pMJy1/F/Np3tEKSsoouOMEgo6VUm2kgrDMxN/J2OE=";
  };

  patches = [
    ./deterministic.patch
  ];

  native_inputs = [ nixpkgs.texinfo nixpkgs.bison nixpkgs.m4 ];

  configure_flags =
    "--target=${host} " +
    "--enable-shared " +
    "--enable-deterministic-archives " +
    "--disable-werror ";

  builder = ./builder.sh;
}
