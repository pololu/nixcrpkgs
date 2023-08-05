{ crossenv, xorgproto, libx11, libxext, libxfixes }:

let
  version = "1.8.1";

  name = "libxi-${version}";

  src = crossenv.nixpkgs.fetchurl {
    url = "https://www.x.org/releases/individual/lib/libXi-${version}.tar.xz";
    hash = "sha256-ib/A6BTyiPeEIC5uX5s2K3iMzs3rB4ZwFF6s2HSWVqc=";
  };

  lib = crossenv.make_derivation rec {
    inherit version name src;

    builder = ./builder.sh;

    configure_flags =
      "--host=${crossenv.host} " +
      "--disable-malloc0returnsnull " +
      "--enable-static " +
      "--disable-shared";

    cross_inputs = [ xorgproto libx11 libxext libxfixes ];

    inherit xorgproto libx11 libxext libxfixes;
  };

  license = crossenv.native.make_derivation {
    name = "${name}-license";
    inherit src;
    builder = ./license_builder.sh;
  };

  license_set =
    xorgproto.license_set //
    libx11.license_set //
    libxext.license_set //
    libxfixes.license_set //
    { "${name}" = license; };

in
  lib // { inherit license_set; }
