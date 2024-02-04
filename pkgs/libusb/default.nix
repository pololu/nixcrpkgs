{ crossenv, libudev }:

let
  version = "1.0.27";

  name = "libusb-${version}";

  src = crossenv.nixpkgs.fetchurl {
    url = "https://github.com/libusb/libusb/releases/download/v${version}/libusb-${version}.tar.bz2";
    hash = "sha256-/6pB10Goo77iRKyOVKcuoFvyh5ZjwJjIL8V1eFNEFXU=";
  };

  lib = crossenv.make_derivation {
    inherit version name src;
    builder = ./builder.sh;
    libudev = if crossenv.os == "linux" then libudev else null;
  };

in
  lib
