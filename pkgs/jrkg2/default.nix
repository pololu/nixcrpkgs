{ crossenv, qt, libusbp }:

crossenv.make_derivation rec {
  name = "jrkg2-${version}";

  version = "1.4.0";  # 2019-03-05

  src = crossenv.nixpkgs.fetchurl {
    url = "https://github.com/pololu/pololu-jrk-g2-software/archive/${version}.tar.gz";
    hash = "sha256-gOqzALqeDv1XPCL75UXvmFq5LX7/tdMpeSLhg1zHScs=";
  };

  builder = ./builder.sh;

  cross_inputs = [ libusbp qt ];
}
