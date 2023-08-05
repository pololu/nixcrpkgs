{ crossenv, xorg-macros, xorgproto }:

let
  version = "1.0.11";

  name = "libxau-${version}";

  src = crossenv.nixpkgs.fetchurl {
    url = "https://www.x.org/archive/individual/lib/libXau-${version}.tar.xz";
    hash = "sha256-8/oygvVXDD9r1iAkRDjb+91YD8gPAvVJWHoPirMpu+s=";
  };

  lib = crossenv.make_derivation rec {
    inherit version name src;

    builder = ./builder.sh;

    configure_flags =
      "--host=${crossenv.host} " +
      "--enable-static " +
      "--disable-shared";

    cross_inputs = [ xorg-macros xorgproto ];

    inherit xorgproto;
  };

  license = crossenv.native.make_derivation {
    name = "${name}-license";
    inherit src;
    builder = ./license_builder.sh;
  };

  license_set =
    xorg-macros.license_set //
    xorgproto.license_set //
    { "${name}" = license; };

in
  lib // { inherit license_set; }
