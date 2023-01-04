{ native, host }:

native.make_derivation rec {
  name = "binutils-${version}-${host}";

  version = "2.39";

  src = native.nixpkgs.fetchurl {
    url = "mirror://gnu/binutils/binutils-${version}.tar.xz";
    hash = "sha256-ZFwl9WO4rcCoHb1qQc/79NNwg6OC4C1dPfT2XAlRbQA=";
  };

  native_inputs = [ native.nixpkgs.texinfo ];

  patches = [
    ./deterministic.patch
  ];

  configure_flags =
    "--target=${host} " +
    "--enable-shared " +
    "--enable-deterministic-archives " +
    "--disable-werror ";

  builder = ./builder.sh;
}
