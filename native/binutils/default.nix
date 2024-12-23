{ env, host }:
let
  nixpkgs = env.nixpkgs;
in
env.make_derivation rec {
  name = "binutils-${version}-${host}";

  version = "2.39";

  src = env.nixpkgs.fetchurl {
    url = "mirror://gnu/binutils/binutils-${version}.tar.xz";
    hash = "sha256-ZFwl9WO4rcCoHb1qQc/79NNwg6OC4C1dPfT2XAlRbQA=";
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
