{ crossenv }:

let
  version = "1.20.0";

  name = "xorg-macros-${version}";

  src = crossenv.nixpkgs.fetchurl {
    url = "https://www.x.org/releases/individual/util/util-macros-${version}.tar.gz";
    hash = "sha256-ja82kT1VGpD9EBPLB4QBN12rrgIctHE7myVqcPAO63Q=";
  };

  lib = crossenv.native.make_derivation {
    inherit version name src;
    builder = ./builder.sh;
    pkgconfig = crossenv.nixpkgs.pkgconfig;
  };

  license = crossenv.native.make_derivation {
    name = "${name}-license";
    inherit src;
    builder = ./license_builder.sh;
  };

  license_set = { "${name}" = license; };

in
  lib // { inherit license_set; }
