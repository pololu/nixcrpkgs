{ crossenv, libxcb, xcb-util }:

let
  version = "0.4.1";

  name = "xcb-util-image-${version}";

  src = crossenv.nixpkgs.fetchurl {
    url = "https://xcb.freedesktop.org/dist/xcb-util-image-${version}.tar.xz";
    hash = "sha256-zK2O5drbEnH9RyetFNm9d6ZOUFYIdmxOmCZ9mu3kDT0=";
  };

  lib = crossenv.make_derivation rec {
    inherit version name src;
    builder = ./builder.sh;

    configure_flags =
      "--host=${crossenv.host} " +
      "--enable-static " +
      "--disable-shared";

    cross_inputs = [ libxcb xcb-util ];

    inherit libxcb;
    libxcb_util = xcb-util;
  };

  license = crossenv.native.make_derivation {
    name = "${name}-license";
    inherit src;
    builder = ./license_builder.sh;
  };

  license_set =
    libxcb.license_set //
    xcb-util.license_set //
    { "${name}" = license; };

in
  lib // { inherit license_set; }
