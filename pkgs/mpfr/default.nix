{ crossenv, gmp }:

crossenv.make_derivation rec {
  name = "mpfr-${version}";

  version = "4.1.0";

  src = crossenv.nixpkgs.fetchurl {
    url = "https://www.mpfr.org/mpfr-current/mpfr-${version}.tar.xz";
    sha256 = "0zwaanakrqjf84lfr5hfsdr7hncwv9wj0mchlr7cmxigfgqs760c";
  };

  inherit gmp;

  # native_inputs = [ crossenv.nixpkgs.lzip crossenv.nixpkgs.m4 ];

  builder = ./builder.sh;
}
