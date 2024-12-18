{ env, host }:
let
  nixpkgs = env.nixpkgs;
in
env.make_derivation rec {
  name = "binutils-${version}-${host}";

  version = "2.43.1";

  src = env.nixpkgs.fetchurl {
    url = "mirror://gnu/binutils/binutils-${version}.tar.xz";
    hash = "sha256-E/dCAqPExREYt5ejnqQgDT9s++Ik2m0dlbuThIATLf0=";
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
