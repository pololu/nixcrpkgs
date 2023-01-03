{ crossenv, qt, libusbp }:

crossenv.make_derivation rec {
  name = "pavr2-${version}";

  version = "a80b4b6";  # 2020-11-30

  src = crossenv.nixpkgs.fetchurl {
    url = "https://github.com/pololu/pololu-usb-avr-programmer-v2/archive/${version}.tar.gz";
    hash = "sha256-ciB53Rw+K7tXPR0ILcteWRttY80wV/MAmd8IuQkqOOU=";
  };

  builder = ./builder.sh;

  cross_inputs = [ libusbp qt ];
}
