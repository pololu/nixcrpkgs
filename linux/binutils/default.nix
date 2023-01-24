# We cannot use binutils 2.31 because then we get a segmentation fault in our
# hello world program, which comes from static_init_tls() in Musl 1.1.20.

{ native, host }:

native.make_derivation rec {
  name = "binutils-${version}-${host}";

  version = "2.40";

  src = native.nixpkgs.fetchurl {
    url = "mirror://gnu/binutils/binutils-${version}.tar.xz";
    hash = "sha256-D4pMJy1/F/Np3tEKSsoouOMEgo6VUm2kgrDMxN/J2OE=";
  };

  patches = [
    ./deterministic.patch
  ];

  native_inputs = [ native.nixpkgs.texinfo native.nixpkgs.bison ];

  configure_flags =
    "--target=${host} " +
    "--enable-shared " +
    "--enable-deterministic-archives " +
    "--disable-werror ";

  builder = ./builder.sh;
}
