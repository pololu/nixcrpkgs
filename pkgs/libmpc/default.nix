{ env, gmp, mpfr }:

env.make_derivation rec {
  name = "libmpc-${version}";

  version = "1.2.1";

  src = env.nixpkgs.fetchurl {
    url = "https://ftp.gnu.org/gnu/mpc/mpc-${version}.tar.gz";
    sha256 = "0n846hqfqvmsmim7qdlms0qr86f1hck19p12nq3g3z2x74n3sl0p";
  };

  configure_flags =
    (if env.is_cross then "--host=${env.host} " else "") +
    "--disable-shared " +
    "--with-gmp=${gmp} " +
    "--with-mpfr=${mpfr}";

  builder = ./builder.sh;
}
