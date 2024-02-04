{ crossenv, libudev }:

let
  version = "1.3.1";

  name = "libusbp-${version}";

  src = crossenv.nixpkgs.fetchurl {
    url = "https://github.com/pololu/libusbp/archive/${version}.tar.gz";
    hash = "sha256-MUulLNn9dLpZQhPzJ3a5aAXPuFJOr2zeAF9+bxN6upk=";
  };

  lib = crossenv.make_derivation {
    inherit version name src;
    builder = ./builder.sh;

    cross_inputs =
      if crossenv.os == "linux" then
        [ libudev ]
      else
        [];

    libudev = if crossenv.os == "linux" then libudev else null;
  };

  examples = crossenv.make_derivation {
    name = "${name}-examples";
    inherit src version;
    builder = ./examples_builder.sh;
    cross_inputs = [ lib ];
  };

  license = crossenv.native.make_derivation {
    name = "${name}-license";
    inherit src;
    builder = ./license_builder.sh;
  };

  license_set =
    (if crossenv.os == "linux" then libudev.license_set else {}) //
    { "${name}" = license; };
in
  lib // { inherit examples license_set; }
