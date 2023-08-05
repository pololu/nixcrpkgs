{ crossenv }:

let
  version = "1.15.2";

  name = "xcb-proto-${version}";

  src = crossenv.nixpkgs.fetchurl {
    url = "https://xcb.freedesktop.org/dist/xcb-proto-${version}.tar.xz";
    hash = "sha256-cHK+sfaAov4/nlNbeXwUbSJSiZDHL2PdtJ0vNQo2U+0=";
  };

  lib = crossenv.native.make_derivation rec {
    inherit version name src;
    builder = ./builder.sh;
    native_inputs = [ crossenv.nixpkgs.python3 ];
  };

  license = crossenv.native.make_derivation {
    name = "${name}-license";
    inherit src;
    builder = ./license_builder.sh;
  };

  license_set = { "${name}" = license; };

in
  lib // { inherit license_set; }
