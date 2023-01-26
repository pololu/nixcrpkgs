{ crossenv, libxcb }:

let
  version = "1.5.0";

  name = "libxkbcommon-${version}";

  nixpkgs = crossenv.nixpkgs;

  src = nixpkgs.fetchurl {
    url = "https://github.com/xkbcommon/libxkbcommon/archive/xkbcommon-${version}.tar.gz";
    hash = "sha256-BT5qaiwxeeuiDDragn+4gzpmY7f/0nj9uFMMPL+SR4A=";
  };

  lib = crossenv.make_derivation rec {
    inherit version name src;

    builder = ./builder.sh;

    configure_flags =
      "--buildtype release " +
      "--default-library static " +
      "-Denable-xkbregistry=false " +
      "-Denable-wayland=false " +
      "-Denable-docs=false";

    cross_inputs = [ libxcb ];

    native_inputs = [ nixpkgs.meson nixpkgs.bison ];
  };

  license = crossenv.native.make_derivation {
    name = "${name}-license";
    inherit src;
    builder = ./license_builder.sh;
  };

  license_set =
    { "${name}" = license; };

in
  lib // { inherit license_set; }
