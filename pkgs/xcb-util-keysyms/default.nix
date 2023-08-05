{ crossenv, libxcb }:

let
  version = "0.4.1";

  name = "xcb-util-keysyms-${version}";

  src = crossenv.nixpkgs.fetchurl {
    url = "https://xcb.freedesktop.org/dist/xcb-util-keysyms-${version}.tar.xz";
    hash = "sha256-fCYKUpRBKu1CnfHaL4r9O9B7fLo/7HcvuhWmE6bVxjg=";
  };

  lib = crossenv.make_derivation rec {
    inherit version name src;

    builder = ./builder.sh;

    configure_flags =
      "--host=${crossenv.host} " +
      "--enable-static " +
      "--disable-shared";

    cross_inputs = [ libxcb ];
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
