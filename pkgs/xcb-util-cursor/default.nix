{ crossenv, libxcb, xcb-util, xcb-util-image, xcb-util-renderutil }:

let
  version = "0.1.4";

  name = "xcb-util-cursor-${version}";

  src = crossenv.nixpkgs.fetchurl {
    url = "https://xcb.freedesktop.org/dist/xcb-util-cursor-${version}.tar.xz";
    hash = "sha256-KNz+kLyrezVhq+DdWOtoMqqcx3z+QvzfpOviDWBSMfs=";
  };

  lib = crossenv.make_derivation rec {
    inherit version name src;
    builder = ./builder.sh;

    configure_flags =
      "--host=${crossenv.host} " +
      "--enable-static " +
      "--disable-shared";

    native_inputs = [ crossenv.nixpkgs.m4 ];

    cross_inputs = [ libxcb xcb-util-image xcb-util-renderutil ];

    inherit libxcb;
    xcb_util_image = xcb-util-image;
    xcb_util_renderutil = xcb-util-renderutil;
  };

  license = crossenv.native.make_derivation {
    name = "${name}-license";
    inherit src;
    builder = ./license_builder.sh;
  };

  license_set =
    libxcb.license_set //
    xcb-util.license_set //
    xcb-util-image.license_set //
    xcb-util-renderutil.license_set //
    { "${name}" = license; };

in
  lib // { inherit license_set; }
