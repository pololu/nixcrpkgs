{ crossenv, qt, libusbp }:

crossenv.make_derivation rec {
  name = "pavr2-${version}";

  version = "f5a476d";  # 2023-06-20

  src = crossenv.nixpkgs.fetchurl {
    url = "https://github.com/pololu/pololu-usb-avr-programmer-v2/archive/${version}.tar.gz";
    hash = "sha256-GAb4OvfF8NUxbtVKfT4NnRgjnkP6iurOfmHr5ly/yRQ=";
  };

  builder = ./builder.sh;

  cross_inputs = [ libusbp qt ];
}
