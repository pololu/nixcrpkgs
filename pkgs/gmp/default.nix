{ crossenv }:

crossenv.make_derivation rec {
  name = "gmp-${version}";

  version = "6.2.1";

  src = crossenv.nixpkgs.fetchurl {
    url = "https://gmplib.org/download/gmp/gmp-${version}.tar.lz";
    sha256 = "0hbvqsgryn84zg7p1l4i6wfmyfsmb4zyzja8kj2b40886w6lyzrc";
  };

  native_inputs = [ crossenv.nixpkgs.lzip crossenv.nixpkgs.m4 ];

  builder = ./builder.sh;
}
