{ env }:

env.make_derivation rec {
  name = "gmp-${version}";

  version = "6.2.1";

  src = env.nixpkgs.fetchurl {
    url = "https://gmplib.org/download/gmp/gmp-${version}.tar.lz";
    sha256 = "0hbvqsgryn84zg7p1l4i6wfmyfsmb4zyzja8kj2b40886w6lyzrc";
  };

  native_inputs = [ env.nixpkgs.lzip env.nixpkgs.m4 ];

  configure_flags =
    (if env.is_cross then "--host=${env.host} " else "") +
    "--disable-shared";

  builder = ./builder.sh;
}
