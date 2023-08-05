{ crossenv }:

let
  version = "1.5.0";

  name = "xtrans-${version}";

  src = crossenv.nixpkgs.fetchurl {
    url = "https://xorg.freedesktop.org/releases/individual/lib/xtrans-${version}.tar.xz";
    hash = "sha256-G6S3A2lr/dv0C6zyW85OPvsqAIiHjwF6UOmISwyPsb0=";
  };

  lib = crossenv.native.make_derivation rec {
    inherit version name src;
    builder = ./builder.sh;
  };

  license = crossenv.native.make_derivation {
    name = "${name}-license";
    inherit src;
    builder = ./license_builder.sh;
  };

  license_set = { "${name}" = license; };

in
  lib // { inherit license_set; }
