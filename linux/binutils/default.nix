{ native, host }:
let
  nixpkgs = native.nixpkgs;
in
native.make_derivation rec {
  name = "binutils-${version}-${host}";

  version = "2.42";

  src = native.nixpkgs.fetchurl {
    url = "mirror://gnu/binutils/binutils-${version}.tar.xz";
    hash = "sha256-9uTUH9X8d4sGt4kUV7NiDaXs6hAGxqSkGumYEJ+FqAA=";
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
