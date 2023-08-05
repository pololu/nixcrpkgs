{ crossenv, libxcb }:

let
  version = "0.3.10";

  name = "xcb-util-renderutil-${version}";

  src = crossenv.nixpkgs.fetchurl {
    url = "https://xcb.freedesktop.org/dist/xcb-util-renderutil-${version}.tar.xz";
    hash = "sha256-PhXU8OItjdv7ufXXfbQ+rNejBAKb8lphZsxjyqltBLo=";
  };

  lib = crossenv.make_derivation {
    inherit version name src;

    builder = ./builder.sh;

    configure_flags =
      "--host=${crossenv.host} " +
      "--enable-static " +
      "--disable-shared";

    cross_inputs = [ libxcb ];

    xcb = libxcb;
  };

  license = crossenv.native.make_derivation {
    name = "${name}-license";
    inherit src;
    builder = ./license_builder.sh;
  };

  license_set =
    libxcb.license_set //
    { "${name}" = license; };

in
  lib // { inherit license_set; }
