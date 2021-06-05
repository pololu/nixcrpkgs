{ env, gmp }:

env.make_derivation rec {
  name = "mpfr-${version}";

  version = "4.1.0";

  src = env.nixpkgs.fetchurl {
    url = "https://www.mpfr.org/mpfr-current/mpfr-${version}.tar.xz";
    sha256 = "0zwaanakrqjf84lfr5hfsdr7hncwv9wj0mchlr7cmxigfgqs760c";
  };

  configure_flags =
    (if env.is_cross then "--host=${env.host} " else "") +
    "--disable-shared " +
    "--with-gmp=${gmp}";

  builder = ./builder.sh;
}
