{ crossenv, gmp, mpfr }:

crossenv.make_derivation rec {
  name = "libmpc-${version}";

  version = "1.2.1";

  src = crossenv.nixpkgs.fetchurl {
    url = "https://ftp.gnu.org/gnu/mpc/mpc-${version}.tar.gz";
    sha256 = "0n846hqfqvmsmim7qdlms0qr86f1hck19p12nq3g3z2x74n3sl0p";
  };

  inherit gmp mpfr;

  builder = ./builder.sh;
}
