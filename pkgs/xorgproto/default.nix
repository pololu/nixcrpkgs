{ crossenv, xorg-macros }:

let
  version = "2023-07-19";

  name = "xorgproto-${version}";

  src = crossenv.nixpkgs.fetchgit {
    url = "https://anongit.freedesktop.org/git/xorg/proto/xorgproto";
    rev = "704a75eecdf177a8b18ad7e35813f2f979b0c277";
    hash = "sha256-pt7zUKL6xtNZpBXYzXF8mfltuUslrTIa23rIRMro5U8=";
  };

  lib = crossenv.native.make_derivation rec {
    inherit version name src;

    builder = ./builder.sh;

    native_inputs = [
      crossenv.nixpkgs.autoconf
      crossenv.nixpkgs.automake
    ];

    ACLOCAL_PATH = "${xorg-macros}/lib/aclocal";
  };

  license = crossenv.native.make_derivation {
    name = "${name}-license";
    inherit src;
    builder = ./license_builder.sh;
  };

  license_set =
    xorg-macros.license_set //
    { "${name}" = license; };

in
  lib // { inherit license license_set; }
