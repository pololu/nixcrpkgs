{ crossenv, libxcb }:

let
  version = "0.4.2";

  name = "xcb-util-wm-${version}";

  src = crossenv.nixpkgs.fetchurl {
    url = "https://xcb.freedesktop.org/dist/xcb-util-wm-${version}.tar.xz";
    hash = "sha256-YsNOIdBiZGh/rqftv2NjLJ8E1V5yEUqkpXu5Xk+Iigs=";
  };

  lib = crossenv.make_derivation rec {
    inherit version name src;

    builder = ./builder.sh;

    configure_flags =
      "--host=${crossenv.host} " +
      "--enable-static " +
      "--disable-shared";

    cross_inputs = [ libxcb ];

    native_inputs = [ crossenv.nixpkgs.m4 ];
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
