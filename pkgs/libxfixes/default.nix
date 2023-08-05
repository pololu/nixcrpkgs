{ crossenv, xorgproto, libx11 }:

let
  version = "6.0.1";

  name = "libxfixes-${version}";

  src = crossenv.nixpkgs.fetchurl {
    url = "https://www.x.org/releases/individual/lib/libXfixes-${version}.tar.xz";
    hash = "sha256-tpX5PNJJlCGrAtInREWOZQzMiMHUyBMNYCACE6vALVg=";
  };

  lib = crossenv.make_derivation rec {
    inherit version name src;

    builder = ./builder.sh;

    configure_flags =
      "--host=${crossenv.host} " +
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
