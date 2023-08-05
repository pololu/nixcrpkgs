{ crossenv, xorgproto, libx11 }:

let
  version = "1.3.5";

  name = "libxext-${version}";

  src = crossenv.nixpkgs.fetchurl {
    url = "https://www.x.org/releases/individual/lib/libXext-${version}.tar.xz";
    hash = "sha256-2xTAyJXFfqM6hVnejLK5PcdsQupKOeKU0XWTihM9e8o=";
  };

  lib = crossenv.make_derivation rec {
    inherit version name src;

    builder = ./builder.sh;

    configure_flags =
      "--host=${crossenv.host} " +
      "--disable-malloc0returnsnull " +
      "--enable-static " +
      "--disable-shared";

    cross_inputs = [ xorgproto libx11 ];

    inherit xorgproto libx11;
  };

  license = crossenv.native.make_derivation {
    name = "${name}-license";
    inherit src;
    builder = ./license_builder.sh;
  };

  license_set =
    xorgproto.license_set //
    libx11.license_set //
    { "${name}" = license; };

in
  lib // { inherit license_set; }

